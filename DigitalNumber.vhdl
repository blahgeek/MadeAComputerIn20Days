library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DigitalNumber is
  port (
    clock: in std_logic;
    reset: in std_logic;
    value: in std_logic_vector(3 downto 0);
    DYP: out std_logic_vector(6 downto 0)) ;
end entity ; -- DigitalNumber


architecture arch of DigitalNumber is

begin

    process( clock, reset)
    begin

        if reset = '1' then
            DYP <= (others => '0');
        elsif rising_edge(clock) then
            case( value ) is
            
                when "0000" => DYP <= "0111111";
                when "0001" => DYP <= "0000110";
                when "0010" => DYP <= "1011011";
                when "0011" => DYP <= "1001111";
                when "0100" => DYP <= "1100110";
                when "0101" => DYP <= "1101101";
                when "0110" => DYP <= "1111101";
                when "0111" => DYP <= "0000111";
                when "1000" => DYP <= "1111111";
                when "1001" => DYP <= "1101111";
                when "1010" => DYP <= "1110111";
                when "1011" => DYP <= "1111100";
                when "1100" => DYP <= "0111001";
                when "1101" => DYP <= "1011110";
                when "1110" => DYP <= "1111001";
                when "1111" => DYP <= "1110001";
                when others => DYP <= (others => '0');
                    
            end case ;
        end if;
        
    end process ; -- identifier

end architecture ; -- arch