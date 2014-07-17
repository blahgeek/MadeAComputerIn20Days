library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity DummyTLB is
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
end entity ; -- TLB


architecture arch of DummyTLB is

begin

    instruction_real_addr(19 downto 18) <= (others => '0');
    instruction_real_addr(17 downto 0) <= instruction_virt_addr(17 downto 0);
    instruction_bad <= '0';

    data_real_addr(19 downto 18) <= (others => '0');
    data_real_addr(17 downto 0) <= data_virt_addr(17 downto 0);
    data_bad <= '0';

end architecture ; -- arch
