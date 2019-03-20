--
-- AUTHOR=EMARD
-- LICENSE=BSD
--

-- VHDL Wrapper for verlog

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.f32c_pack.all;

entity fake_differential is
  generic
  (
    C_ddr: integer := 0
  );
  port
  (
    clk_shift: in std_logic;
    in_clock, in_red, in_green, in_blue: in std_logic_vector(1 downto 0);
    out_p, out_n: out std_logic_vector(3 downto 0)
  );
end;

architecture syn of fake_differential is
  component fake_differential_v -- verilog name and its parameters
    generic
    (
      C_ddr: integer := 0
    );
    port
    (
      clk_shift: in std_logic;
      in_clock, in_red, in_green, in_blue: in std_logic_vector(1 downto 0);
      out_p, out_n: out std_logic_vector(3 downto 0)
    );
  end component;
begin
  fake_differential_v_inst: fake_differential_v
  generic map
  (
    C_ddr => C_ddr
  )
  port map
  (
    clk_shift => clk_shift,
    in_clock => in_clock,
    in_red => in_red,
    in_green => in_green,
    in_blue => in_blue,
    out_p => out_p,
    out_n => out_n
  );
end syn;
