library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity InterruptHandler is
  port (
    clock: in std_logic;
    reset: in std_logic;

    mask: in std_logic_vector(7 downto 0);

    timer_int: in std_logic;
    uart_int: in std_logic;

    int: out std_logic := '0';
    int_numbers: out std_logic_vector(7 downto 0) := (others => '0')
  ) ;
end entity ; -- InterruptHandler


architecture arch of InterruptHandler is

    constant timerNo: Integer := 7;
    constant uartNo: Integer := 4;

    signal timer_int_masked: std_logic := '0';
    signal uart_int_masked: std_logic := '0';

begin

    timer_int_masked <= timer_int and mask(timerNo);
    uart_int_masked <= uart_int and mask(uartNo);

    int <= timer_int_masked or uart_int_masked; -- or anything else

    int_numbers(timerNo) <= timer_int_masked;
    int_numbers(uartNo) <= uart_int_masked;

end architecture ; -- arch
