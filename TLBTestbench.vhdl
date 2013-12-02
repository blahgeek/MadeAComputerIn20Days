library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity TLBTestbench is
end entity ; -- TLBTestbench


architecture arch of TLBTestbench is

component TLB is
  port (
    clock: in std_logic;
    reset: in std_logic;

    instruction_virt_addr: in std_logic_vector(19 downto 0);
    instruction_real_addr: out std_logic_vector(19 downto 0);
    instruction_bad: out std_logic:= '0';

    data_virt_addr: in std_logic_vector(19 downto 0);
    data_real_addr: out std_logic_vector(19 downto 0);
    data_bad: out std_logic:= '0';

    set_do: in std_logic;
    set_index: in std_logic_vector(2 downto 0);
    set_entry: in std_logic_vector(63 downto 0)
  ) ;
end component ; -- TLB

    signal clock: std_logic;
    signal virt_addr, real_addr: std_logic_vector(19 downto 0);
    signal bad: std_logic;
    signal set_do: std_logic;
    signal set_index: std_logic_vector(2 downto 0);
    signal set_entry: std_logic_vector(63 downto 0);

    constant clk_period :time :=20 ns;

begin

    tlb0: TLB port map (clock, '0',
        virt_addr, real_addr, bad,
        virt_addr, open, open,
        set_do, set_index, set_entry);

    process begin
        clock <= '0';
        set_do <= '1';
        set_index <= (others => '0');
        set_entry(63) <= '0';
        set_entry(62 downto 44) <= (others => '0');
        set_entry(43 downto 24) <= (others => '1');
        set_entry(23) <= '1';
        set_entry(22 downto 0) <= (others => '0');
        virt_addr <= (others => '0');
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        virt_addr(0) <= '1';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        virt_addr(0) <= '0';
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        wait;
    end process;


end architecture ; -- arch