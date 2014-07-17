library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity TLB is
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


architecture arch of TLB is

    type entrys is array (0 to 7) of STD_LOGIC_VECTOR(63 downto 0);
    signal data: entrys := (others => (others => '0'));

    signal data_found: std_logic_vector(20 downto 0);
    signal inst_found: std_logic_vector(20 downto 0);

begin

    process(set_do, reset) begin
        if reset = '1' then
            data <= (others => (others => '0'));
        elsif rising_edge(set_do) then
            data(to_integer(unsigned(set_index))) <= set_entry;
        end if;
    end process;

    instruction_real_addr <= inst_found(19 downto 0);
    instruction_bad <= not inst_found(20);

    data_real_addr <= data_found(19 downto 0);
    data_bad <= not data_found(20);

    inst_found <= 
        ('1' & "00" & instruction_virt_addr(17 downto 0)) 
            when instruction_virt_addr(19 downto 18) = "10" else
        ('1' & data(0)(43 downto 24))
            when instruction_virt_addr(0) = '0' and 
                instruction_virt_addr(19 downto 1) = data(0)(62 downto 44) and
                data(0)(22) = '1' else
        ('1' & data(1)(43 downto 24))
            when instruction_virt_addr(0) = '0' and 
                instruction_virt_addr(19 downto 1) = data(1)(62 downto 44) and
                data(1)(22) = '1' else
        ('1' & data(2)(43 downto 24))
            when instruction_virt_addr(0) = '0' and 
                instruction_virt_addr(19 downto 1) = data(2)(62 downto 44) and
                data(2)(22) = '1' else
        ('1' & data(3)(43 downto 24))
            when instruction_virt_addr(0) = '0' and 
                instruction_virt_addr(19 downto 1) = data(3)(62 downto 44) and
                data(3)(22) = '1' else
        ('1' & data(4)(43 downto 24))
            when instruction_virt_addr(0) = '0' and 
                instruction_virt_addr(19 downto 1) = data(4)(62 downto 44) and
                data(4)(22) = '1' else
        ('1' & data(5)(43 downto 24))
            when instruction_virt_addr(0) = '0' and 
                instruction_virt_addr(19 downto 1) = data(5)(62 downto 44) and
                data(5)(22) = '1' else
        ('1' & data(6)(43 downto 24))
            when instruction_virt_addr(0) = '0' and 
                instruction_virt_addr(19 downto 1) = data(6)(62 downto 44) and
                data(6)(22) = '1' else
        ('1' & data(7)(43 downto 24))
            when instruction_virt_addr(0) = '0' and 
                instruction_virt_addr(19 downto 1) = data(7)(62 downto 44) and
                data(7)(22) = '1' else
        ('1' & data(0)(21 downto 2))
            when instruction_virt_addr(0) = '1' and 
                instruction_virt_addr(19 downto 1) = data(0)(62 downto 44) and
                data(0)(0) = '1' else
        ('1' & data(1)(21 downto 2))
            when instruction_virt_addr(0) = '1' and 
                instruction_virt_addr(19 downto 1) = data(1)(62 downto 44) and
                data(1)(0) = '1' else
        ('1' & data(2)(21 downto 2))
            when instruction_virt_addr(0) = '1' and 
                instruction_virt_addr(19 downto 1) = data(2)(62 downto 44) and
                data(2)(0) = '1' else
        ('1' & data(3)(21 downto 2))
            when instruction_virt_addr(0) = '1' and 
                instruction_virt_addr(19 downto 1) = data(3)(62 downto 44) and
                data(3)(0) = '1' else
        ('1' & data(4)(21 downto 2))
            when instruction_virt_addr(0) = '1' and 
                instruction_virt_addr(19 downto 1) = data(4)(62 downto 44) and
                data(4)(0) = '1' else
        ('1' & data(5)(21 downto 2))
            when instruction_virt_addr(0) = '1' and 
                instruction_virt_addr(19 downto 1) = data(5)(62 downto 44) and
                data(5)(0) = '1' else
        ('1' & data(6)(21 downto 2))
            when instruction_virt_addr(0) = '1' and 
                instruction_virt_addr(19 downto 1) = data(6)(62 downto 44) and
                data(6)(0) = '1' else
        ('1' & data(7)(21 downto 2))
            when instruction_virt_addr(0) = '1' and 
                instruction_virt_addr(19 downto 1) = data(7)(62 downto 44) and
                data(7)(0) = '1' else
        (others => '0');

    data_found <= 
        ('1' & "00" & data_virt_addr(17 downto 0)) 
            when data_virt_addr(19 downto 18) = "10" else
        ('1' & data(0)(43 downto 24))
            when data_virt_addr(0) = '0' and 
                data_virt_addr(19 downto 1) = data(0)(62 downto 44) and
                data(0)(22) = '1' else
        ('1' & data(1)(43 downto 24))
            when data_virt_addr(0) = '0' and 
                data_virt_addr(19 downto 1) = data(1)(62 downto 44) and
                data(1)(22) = '1' else
        ('1' & data(2)(43 downto 24))
            when data_virt_addr(0) = '0' and 
                data_virt_addr(19 downto 1) = data(2)(62 downto 44) and
                data(2)(22) = '1' else
        ('1' & data(3)(43 downto 24))
            when data_virt_addr(0) = '0' and 
                data_virt_addr(19 downto 1) = data(3)(62 downto 44) and
                data(3)(22) = '1' else
        ('1' & data(4)(43 downto 24))
            when data_virt_addr(0) = '0' and 
                data_virt_addr(19 downto 1) = data(4)(62 downto 44) and
                data(4)(22) = '1' else
        ('1' & data(5)(43 downto 24))
            when data_virt_addr(0) = '0' and 
                data_virt_addr(19 downto 1) = data(5)(62 downto 44) and
                data(5)(22) = '1' else
        ('1' & data(6)(43 downto 24))
            when data_virt_addr(0) = '0' and 
                data_virt_addr(19 downto 1) = data(6)(62 downto 44) and
                data(6)(22) = '1' else
        ('1' & data(7)(43 downto 24))
            when data_virt_addr(0) = '0' and 
                data_virt_addr(19 downto 1) = data(7)(62 downto 44) and
                data(7)(22) = '1' else
        ('1' & data(0)(21 downto 2))
            when data_virt_addr(0) = '1' and 
                data_virt_addr(19 downto 1) = data(0)(62 downto 44) and
                data(0)(0) = '1' else
        ('1' & data(1)(21 downto 2))
            when data_virt_addr(0) = '1' and 
                data_virt_addr(19 downto 1) = data(1)(62 downto 44) and
                data(1)(0) = '1' else
        ('1' & data(2)(21 downto 2))
            when data_virt_addr(0) = '1' and 
                data_virt_addr(19 downto 1) = data(2)(62 downto 44) and
                data(2)(0) = '1' else
        ('1' & data(3)(21 downto 2))
            when data_virt_addr(0) = '1' and 
                data_virt_addr(19 downto 1) = data(3)(62 downto 44) and
                data(3)(0) = '1' else
        ('1' & data(4)(21 downto 2))
            when data_virt_addr(0) = '1' and 
                data_virt_addr(19 downto 1) = data(4)(62 downto 44) and
                data(4)(0) = '1' else
        ('1' & data(5)(21 downto 2))
            when data_virt_addr(0) = '1' and 
                data_virt_addr(19 downto 1) = data(5)(62 downto 44) and
                data(5)(0) = '1' else
        ('1' & data(6)(21 downto 2))
            when data_virt_addr(0) = '1' and 
                data_virt_addr(19 downto 1) = data(6)(62 downto 44) and
                data(6)(0) = '1' else
        ('1' & data(7)(21 downto 2))
            when data_virt_addr(0) = '1' and 
                data_virt_addr(19 downto 1) = data(7)(62 downto 44) and
                data(7)(0) = '1' else
        (others => '0');

end architecture ; -- arch
