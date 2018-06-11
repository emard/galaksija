--
-- AUTHOR=EMARD
-- LICENSE=BSD
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- vhdl wrapper for verilog module galaksija_v.v

entity galaksija is
  port
  (
      clk, pixclk, locked, ser_rx: in std_logic;
      LCD_DAT: out std_logic_vector(7 downto 0);
      LCD_CLK, LCD_HS, LCD_VS, LCD_DEN, LCD_RST, LCD_PWM, mreq_n: out std_logic
  );
end;

architecture syn of galaksija is
  component galaksija_v
    port (
      clk, pixclk, locked, ser_rx: in std_logic;
      LCD_DAT: out std_logic_vector(7 downto 0);
      LCD_CLK, LCD_HS, LCD_VS, LCD_DEN, LCD_RST, LCD_PWM, mreq_n: out std_logic
    );
  end component;

begin
  galaksija_inst: galaksija_v
  port map
  (
      clk => clk, pixclk => pixclk, locked => locked, ser_rx => ser_rx,
      LCD_DAT => LCD_DAT,
      LCD_CLK => LCD_CLK, LCD_HS => LCD_HS, LCD_VS => LCD_VS, LCD_DEN => LCD_DEN,
      LCD_RST => LCD_RST, LCD_PWM => LCD_PWM, mreq_n => mreq_n
  );
end syn;
