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

begin

    process(clock, reset)
    begin
        if reset = '1' then 
            data <= (others => (others => '0'));
        elsif rising_edge(clock) then
            if set_do = '1' then
                data(to_integer(unsigned(set_index))) <= set_entry;
            end if;
        end if;
    end process;

    process(clock, reset)
    begin
        if reset = '1' then 
            instruction_bad <= '0';
            instruction_real_addr <= (others => '0');
        elsif rising_edge(clock) then
            if instruction_virt_addr(0) = '0' then
                if instruction_virt_addr(19 downto 1) = data(0)(62 downto 44) and data(0)(23) = '1' then
                    instruction_real_addr <= data(0)(43 downto 24);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(1)(62 downto 44) and data(1)(23) = '1' then
                    instruction_real_addr <= data(1)(43 downto 24);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(2)(62 downto 44) and data(2)(23) = '1' then
                    instruction_real_addr <= data(2)(43 downto 24);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(3)(62 downto 44) and data(3)(23) = '1' then
                    instruction_real_addr <= data(3)(43 downto 24);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(4)(62 downto 44) and data(4)(23) = '1' then
                    instruction_real_addr <= data(4)(43 downto 24);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(5)(62 downto 44) and data(5)(23) = '1' then
                    instruction_real_addr <= data(5)(43 downto 24);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(6)(62 downto 44) and data(6)(23) = '1' then
                    instruction_real_addr <= data(6)(43 downto 24);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(7)(62 downto 44) and data(7)(23) = '1' then
                    instruction_real_addr <= data(7)(43 downto 24);
                    instruction_bad <= '0';
                else
                    instruction_real_addr <= (others => '0');
                    instruction_bad <= '1';
                end if;
            else
                if instruction_virt_addr(19 downto 1) = data(0)(62 downto 44) and data(0)(1) = '1' then
                    instruction_real_addr <= data(0)(21 downto 2);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(1)(62 downto 44) and data(1)(1) = '1' then
                    instruction_real_addr <= data(1)(21 downto 2);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(2)(62 downto 44) and data(2)(1) = '1' then
                    instruction_real_addr <= data(2)(21 downto 2);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(3)(62 downto 44) and data(3)(1) = '1' then
                    instruction_real_addr <= data(3)(21 downto 2);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(4)(62 downto 44) and data(4)(1) = '1' then
                    instruction_real_addr <= data(4)(21 downto 2);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(5)(62 downto 44) and data(5)(1) = '1' then
                    instruction_real_addr <= data(5)(21 downto 2);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(6)(62 downto 44) and data(6)(1) = '1' then
                    instruction_real_addr <= data(6)(21 downto 2);
                    instruction_bad <= '0';
                elsif instruction_virt_addr(19 downto 1) = data(7)(62 downto 44) and data(7)(1) = '1' then
                    instruction_real_addr <= data(7)(21 downto 2);
                    instruction_bad <= '0';
                else
                    instruction_real_addr <= (others => '0');
                    instruction_bad <= '1';
                end if;
            end if;
        end if;
    end process;

    process(clock, reset)
    begin
        if reset = '1' then 
            data_bad <= '0';
            data_real_addr <= (others => '0');
        elsif rising_edge(clock) then
            if data_virt_addr(0) = '0' then
                if data_virt_addr(19 downto 1) = data(0)(62 downto 44) and data(0)(23) = '1' then
                    data_real_addr <= data(0)(43 downto 24);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(1)(62 downto 44) and data(1)(23) = '1' then
                    data_real_addr <= data(1)(43 downto 24);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(2)(62 downto 44) and data(2)(23) = '1' then
                    data_real_addr <= data(2)(43 downto 24);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(3)(62 downto 44) and data(3)(23) = '1' then
                    data_real_addr <= data(3)(43 downto 24);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(4)(62 downto 44) and data(4)(23) = '1' then
                    data_real_addr <= data(4)(43 downto 24);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(5)(62 downto 44) and data(5)(23) = '1' then
                    data_real_addr <= data(5)(43 downto 24);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(6)(62 downto 44) and data(6)(23) = '1' then
                    data_real_addr <= data(6)(43 downto 24);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(7)(62 downto 44) and data(7)(23) = '1' then
                    data_real_addr <= data(7)(43 downto 24);
                    data_bad <= '0';
                else
                    data_real_addr <= (others => '0');
                    data_bad <= '1';
                end if;
            else
                if data_virt_addr(19 downto 1) = data(0)(62 downto 44) and data(0)(1) = '1' then
                    data_real_addr <= data(0)(21 downto 2);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(1)(62 downto 44) and data(1)(1) = '1' then
                    data_real_addr <= data(1)(21 downto 2);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(2)(62 downto 44) and data(2)(1) = '1' then
                    data_real_addr <= data(2)(21 downto 2);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(3)(62 downto 44) and data(3)(1) = '1' then
                    data_real_addr <= data(3)(21 downto 2);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(4)(62 downto 44) and data(4)(1) = '1' then
                    data_real_addr <= data(4)(21 downto 2);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(5)(62 downto 44) and data(5)(1) = '1' then
                    data_real_addr <= data(5)(21 downto 2);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(6)(62 downto 44) and data(6)(1) = '1' then
                    data_real_addr <= data(6)(21 downto 2);
                    data_bad <= '0';
                elsif data_virt_addr(19 downto 1) = data(7)(62 downto 44) and data(7)(1) = '1' then
                    data_real_addr <= data(7)(21 downto 2);
                    data_bad <= '0';
                else
                    data_real_addr <= (others => '0');
                    data_bad <= '1';
                end if;
            end if;
        end if;
    end process;

end architecture ; -- arch