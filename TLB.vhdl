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
            if instruction_virt_addr(19 downto 18) = "10" then --kseg0/1
                instruction_real_addr(17 downto 0) <= instruction_virt_addr(17 downto 0);
                instruction_real_addr(19 downto 18) <= "00";
                instruction_bad <= '0';
            elsif instruction_virt_addr(0) = '0' then
                for i in 0 to 7 loop
                    if instruction_virt_addr(19 downto 1) = data(i)(62 downto 44) 
                        and data(i)(22) = '1' then
                        instruction_bad <= '0';
                        instruction_real_addr <= data(i)(43 downto 24);
                    end if;
                end loop ;
            else
                for i in 0 to 7 loop
                    if instruction_virt_addr(19 downto 1) = data(i)(62 downto 44) 
                        and data(i)(0) = '1' then
                        instruction_bad <= '0';
                        instruction_real_addr <= data(i)(21 downto 2);
                    end if;
                end loop ;
            end if;
        end if;
    end process;

    process(clock, reset)
    begin
        if reset = '1' then 
            data_bad <= '0';
            data_real_addr <= (others => '0');
        elsif rising_edge(clock) then
            if data_virt_addr(19 downto 18) = "10" then --kseg0/1
                data_real_addr(17 downto 0) <= data_virt_addr(17 downto 0);
                data_real_addr(19 downto 18) <= "00";
                data_bad <= '0';
            elsif data_virt_addr(0) = '0' then
                for i in 0 to 7 loop
                    if data_virt_addr(19 downto 1) = data(i)(62 downto 44) 
                        and data(i)(22) = '1' then
                        data_bad <= '0';
                        data_real_addr <= data(i)(43 downto 24);
                    end if;
                end loop ;
            else
                for i in 0 to 7 loop
                    if data_virt_addr(19 downto 1) = data(i)(62 downto 44) 
                        and data(i)(0) = '1' then
                        data_bad <= '0';
                        data_real_addr <= data(i)(21 downto 2);
                    end if;
                end loop ;
            end if;
        end if;
    end process;

end architecture ; -- arch
