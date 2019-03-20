----------------------------
-- ULX3S Top level for SNAKE
-- http://github.com/emard
----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

-- vendor specific library for clock, ddr and differential video out
library ecp5u;
use ecp5u.components.all;

entity galaksija_ulx3s is
generic
(
  C_sound: boolean := false -- enable sound output
);
port
(
  clk_25mhz: in std_logic;  -- main clock input from 25MHz clock source

  -- UART0 (FTDI USB slave serial)
  ftdi_rxd: out   std_logic;
  ftdi_txd: in    std_logic;
  -- FTDI additional signaling
  ftdi_nrts: inout  std_logic;
  ftdi_txden: inout std_logic;

  -- UART1 (WiFi serial)
  wifi_rxd: out   std_logic;
  wifi_txd: in    std_logic;
  -- WiFi additional signaling
  wifi_en: inout  std_logic := 'Z'; -- '0' will disable wifi by default
  wifi_gpio0: inout std_logic := 'Z';

  -- ADC MAX11123
  adc_csn, adc_sclk, adc_mosi: out std_logic;
  adc_miso: in std_logic;

  -- SDRAM
  sdram_clk: out std_logic;
  sdram_cke: out std_logic;
  sdram_csn: out std_logic;
  sdram_rasn: out std_logic;
  sdram_casn: out std_logic;
  sdram_wen: out std_logic;
  sdram_a: out std_logic_vector (12 downto 0);
  sdram_ba: out std_logic_vector(1 downto 0);
  sdram_dqm: out std_logic_vector(1 downto 0);
  sdram_d: inout std_logic_vector (15 downto 0);

  -- Onboard blinky
  led: out std_logic_vector(7 downto 0);
  btn: in std_logic_vector(6 downto 0);
  sw: in std_logic_vector(3 downto 0);
  oled_csn, oled_clk, oled_mosi, oled_dc, oled_resn: out std_logic;

  -- GPIO
  gp, gn: inout std_logic_vector(27 downto 0);

  -- SHUTDOWN: logic '1' here will shutdown power on PCB >= v1.7.5
  shutdown: out std_logic := '0';

  -- Audio jack 3.5mm
  audio_l, audio_r, audio_v: inout std_logic_vector(3 downto 0) := (others => 'Z');

  -- Onboard antenna 433 MHz
  ant_433mhz: out std_logic;

  -- Digital Video (differential outputs)
  gpdi_dp, gpdi_dn: out std_logic_vector(3 downto 0);

  -- i2c shared for digital video and RTC
  gpdi_scl, gpdi_sda: inout std_logic;

  -- US2 port
  usb_fpga_dp, usb_fpga_dn: inout std_logic

  -- Flash ROM (SPI0)
  -- commented out because it can't be used as GPIO
  -- when bitstream is loaded from config flash
  --flash_miso   : in      std_logic;
  --flash_mosi   : out     std_logic;
  --flash_clk    : out     std_logic;
  --flash_csn    : out     std_logic;
);
end;

architecture struct of galaksija_ulx3s is
        signal reset_n: std_logic;

	--alias ps2_clk : std_logic is usb_fpga_dp;
	--alias ps2_dat : std_logic is usb_fpga_dn;

	signal clk_pixel, clk_pixel_shift, clkn_pixel_shift, locked: std_logic;

        signal S_LCD_DAT: std_logic_vector(7 downto 0);
	signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(2 downto 0);
	signal S_vga_vsync, S_vga_hsync: std_logic;
	signal S_vga_vblank, S_vga_blank: std_logic;
	signal ddr_d: std_logic_vector(2 downto 0);
	signal ddr_clk: std_logic;
	signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);

	signal audio_data : std_logic_vector(17 downto 0);
	signal S_audio: std_logic_vector(23 downto 0) := (others => '0');
	signal S_spdif_out: std_logic;
begin
  wifi_gpio0 <= btn(0); -- holding reset for 2 sec will activate ESP32 loader
  led(0) <= btn(0); -- visual indication of btn press
  -- btn(0) has inverted logic
  
  process(clk_pixel)
  begin
    if rising_edge(clk_pixel) then
      reset_n <= btn(0) and locked;
    end if;
  end process;

  clkgen: entity work.clk_25_100_125_25
  port map
  (
      clki => clk_25mhz,         --  25 MHz input from board
      clkop => clk_pixel_shift,  -- 125 MHz
      clkos => clkn_pixel_shift, -- 125 MHz inverted
      clkos2 => clk_pixel,       --  25 MHz
      locked => locked           -- PLL READY
  );

  galaksija_module: entity work.galaksija
  port map
  (
    clk        => clk_pixel,
    pixclk     => clk_pixel,
    reset_n    => reset_n,
    ser_rx     => ftdi_txd,
    LCD_DAT    => S_LCD_DAT,
    LCD_HS     => S_vga_hsync,
    LCD_VS     => S_vga_vsync,
    LCD_DEN    => S_vga_blank
  );
  
  S_vga_r(2 downto 1) <= S_LCD_DAT(7 downto 6);
  S_vga_g(2 downto 0) <= S_LCD_DAT(5 downto 3);
  S_vga_b(2 downto 0) <= S_LCD_DAT(2 downto 0);
  
  -- HDMI will report 960x260 @ 76.1 Hz

  -- led(7) <= not S_vga_vsync;
  -- led(1) <= locked;

  vga2dvi_converter: entity work.vga2dvid
  generic map
  (
      C_ddr     => '1',
      C_depth   => 3
  )
  port map
  (
      clk_pixel => clk_pixel, -- 25 MHz
      clk_shift => clk_pixel_shift, -- 5*25 MHz

      in_red   => S_vga_r,
      in_green => S_vga_g,
      in_blue  => S_vga_b,

      in_hsync => S_vga_hsync,
      in_vsync => S_vga_vsync,
      in_blank => S_vga_blank,

      -- single-ended output ready for differential buffers
      out_red   => dvid_red,
      out_green => dvid_green,
      out_blue  => dvid_blue,
      out_clock => dvid_clock
  );

  fake_differential_instance: entity work.fake_differential
  generic map
  (
      C_ddr => 1
  )
  port map
  (
      clk_shift => clk_pixel_shift,
      in_clock => dvid_clock,
      in_red => dvid_red,
      in_green => dvid_green,
      in_blue => dvid_blue,
      out_p => gpdi_dp,
      out_n => gpdi_dn
    );

end struct;
