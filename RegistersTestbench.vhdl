library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity RegistersTestbench is
end entity ; -- RegistersTestbench

architecture arch of RegistersTestbench is

component Registers 
    port(
        clk : in STD_LOGIC;
        RegReadNumberA : in STD_LOGIC_VECTOR(4 downto 0);
        RegReadNumberB : in STD_LOGIC_VECTOR(4 downto 0);
        RegWrite : in STD_LOGIC; 
        RegWriteNumber : in STD_LOGIC_VECTOR(4 downto 0);
        RegWriteValue : in STD_LOGIC_VECTOR(31 downto 0);
        RegReadValueA : out STD_LOGIC_VECTOR(31 downto 0);
        RegReadValueB : out STD_LOGIC_VECTOR(31 downto 0)
        );
end component;

  constant clk_period :time :=20 ns;
  signal clock: STD_LOGIC := '0';
  signal s_write : STD_LOGIC := '0';
  signal s_read_a_num, s_read_b_num, s_write_num: STD_LOGIC_VECTOR(4 downto 0);
  signal s_write_value, s_read_value_a, s_read_value_b: STD_LOGIC_VECTOR(31 downto 0);

begin

    instance: Registers port map (
        clock, s_read_a_num, s_read_b_num, s_write, s_write_num,
        s_write_value, s_read_value_a, s_read_value_b);

    process begin
        s_read_a_num <= "00011";
        s_read_b_num <= "00000";
        s_write <= '1';
        s_write_num <= "00011";
        s_write_value <= x"DEADBEEF";
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        s_read_a_num <= "00000";
        s_read_b_num <= "00011";
        s_write <= '1';
        s_write_num <= "00000";
        s_write_value <= x"DEADBEEF";
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        wait;
    end process;

end architecture ; -- arch