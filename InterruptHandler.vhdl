library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity InterruptHandler is
  port (
    clock: in std_logic;
    reset: in std_logic;

    mask: in std_logic_vector(7 downto 0);

    timer_count: out std_logic_vector(31 downto 0);
    timer_compare: in std_logic_vector(31 downto 0);

    int: out std_logic := '0';
    int_numbers: out std_logic_vector(7 downto 0)
  ) ;
end entity ; -- InterruptHandler


architecture arch of InterruptHandler is

component Timer port (
    clk: in std_logic;
    reset: in std_logic;
    count: buffer std_logic_vector(31 downto 0) := (others => '0');
    compare: in std_logic_vector(31 downto 0);
    int: out std_logic
  );
end component;

    constant timerNo: std_logic_vector(2 downto 0) := "111";
    constant timerNoI: Integer := 7;

    signal timer_int: std_logic := '0';
    signal timer_int_masked: std_logic := '0';

begin

    timer0: Timer port map (
        clock, reset, timer_count, timer_compare, timer_int);
    timer_int_masked <= timer_int and mask(timerNoI);

    int <= timer_int_masked; -- or anything else

    int_numbers(7) <= timer_int_masked;
    int_numbers(6 downto 0) <= (others => '0');

end architecture ; -- arch
