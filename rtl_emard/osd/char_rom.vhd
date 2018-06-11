-- (C)EMARD
-- LICENSE=BSD

-- font 5x7 in human-editable form (strings)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity char_rom is
port (
  clock: in std_logic;
  addr: in integer;
  data: out std_logic_vector(6 downto 0)
);
end;

architecture Behavioral of char_rom is
  constant C_char_count: integer := 17; -- 17 chars to represent 0-F HEX + SPACE
  constant C_char_width: integer := 5; -- 5 pixels wide
  constant C_char_height: integer := 7; -- 7 pixels high

  type T_char is array (0 to C_char_height-1) of string(1 to C_char_width);
  type T_char_set is array (0 to C_char_count-1) of T_char;
  constant C_char_set: T_char_set :=
  (
    (
    " *** ",
    "*   *",
    "*  **",
    "* * *",
    "**  *",
    "*   *",
    " *** "
    ),
    (
    "  *  ",
    " **  ",
    "  *  ",
    "  *  ",
    "  *  ",
    "  *  ",
    " *** "
    ),
    (
    " *** ",
    "*   *",
    "    *",
    "   * ",
    "  *  ",
    " *   ",
    "*****"
    ),
    (
    " *** ",
    "*   *",
    "    *",
    "  ** ",
    "    *",
    "*   *",
    " *** "
    ),
    (
    "   * ",
    "  ** ",
    " * * ",
    "*  * ",
    "*****",
    "   * ",
    "   * "
    ),
    (
    "*****",
    "*    ",
    "**** ",
    "    *",
    "    *",
    "*   *",
    " *** "
    ),
    (
    " *** ",
    "*    ",
    "*    ",
    "**** ",
    "*   *",
    "*   *",
    " *** "
    ),
    (
    "*****",
    "*   *",
    "    *",
    "   * ",
    "  *  ",
    " *   ",
    " *   "
    ),
    (
    " *** ",
    "*   *",
    "*   *",
    " *** ",
    "*   *",
    "*   *",
    " *** "
    ),
    (
    " *** ",
    "*   *",
    "*   *",
    " ****",
    "    *",
    "    *",
    " *** "
    ),
    (
    "  *  ",
    " * * ",
    "*   *",
    "*   *",
    "*****",
    "*   *",
    "*   *"
    ),
    (
    "**** ",
    "*   *",
    "*   *",
    "**** ",
    "*   *",
    "*   *",
    "**** "
    ),
    (
    " *** ",
    "*   *",
    "*    ",
    "*    ",
    "*    ",
    "*   *",
    " *** "
    ),
    (
    "***  ",
    "*  * ",
    "*   *",
    "*   *",
    "*   *",
    "*  * ",
    "***  "
    ),
    (
    "*****",
    "*    ",
    "*    ",
    "**** ",
    "*    ",
    "*    ",
    "*****"
    ),
    (
    "*****",
    "*    ",
    "*    ",
    "**** ",
    "*    ",
    "*    ",
    "*    "
    ),
    (
    "     ",
    "     ",
    "     ",
    "     ",
    "     ",
    "     ",
    "     "
    )
  );

  type T_char_rom is array (0 to C_char_count*C_char_width-1) of std_logic_vector(C_char_height-1 downto 0);
  -- conversion function from char string to char ROM binary
  function char_set2rom(s: T_char_set)
    return T_char_rom
  is
    variable r: T_char_rom;
    constant h: integer := r(0)'length;
    constant w: integer := s(0)(0)'length;
    constant c: integer := s'length;
    variable b: std_logic_vector(h-1 downto 0);
  begin
    for ic in 0 to c-1 loop
      for iw in 0 to w-1 loop
        b:= (others => '0');
        for ih in 0 to h-1 loop
          if s(ic)(ih)(iw+1) /= ' ' then
            b(ih) := '1';
          end if;
        end loop;
        r(ic*w+iw) := b;
      end loop;
    end loop;
    return r;
  end function;
  constant C_char_rom: T_char_rom := char_set2rom(C_char_set);

  -- same or similar as above
  type T_char_rom2 is array (0 to C_char_count*C_char_width-1) of std_logic_vector(7 downto 0);
  constant C_char_rom2: T_char_rom2 :=
  (
    x"3E", x"51", x"49", x"45", x"3E", -- 0
    x"00", x"42", x"7F", x"40", x"00", -- 1
    x"42", x"61", x"51", x"49", x"46", -- 2
    x"21", x"41", x"45", x"4B", x"31", -- 3
    x"18", x"14", x"12", x"7F", x"10", -- 4
    x"27", x"45", x"45", x"45", x"39", -- 5
    x"3C", x"4A", x"49", x"49", x"30", -- 6
    x"01", x"71", x"09", x"05", x"03", -- 7
    x"36", x"49", x"49", x"49", x"36", -- 8
    x"06", x"49", x"49", x"29", x"1E", -- 9

    x"7C", x"12", x"11", x"12", x"7C", -- A
    x"7F", x"49", x"49", x"49", x"36", -- B
    x"3E", x"41", x"41", x"41", x"22", -- C
    x"7F", x"41", x"41", x"22", x"1C", -- D
    x"7F", x"49", x"49", x"49", x"41", -- E
    x"7F", x"09", x"09", x"09", x"01", -- F

    others => (others => '0') -- SPACE
  );

  signal S_rom_addr: integer range 0 to C_char_count*C_char_width-1;
  signal R_data: std_logic_vector(C_char_height-1 downto 0);
begin
  S_rom_addr <= addr; -- addr when addr < C_char_count*C_char_width else 0;
  process(clock)
  begin
    if rising_edge(clock) then
      R_data <= C_char_rom(S_rom_addr)(6 downto 0);
    end if;
  end process;
  data <= R_data;
end Behavioral;
