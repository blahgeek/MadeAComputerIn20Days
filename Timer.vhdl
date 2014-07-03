library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity Timer is
  port (
    clk: in std_logic;
    reset: in std_logic;
    count: buffer std_logic_vector(31 downto 0) := (others => '0');
    compare: in std_logic_vector(31 downto 0);
    int: out std_logic
  ) ;
end entity ; -- Timer


architecture arch of Timer is

    type state_type is (s0, s1, s2, s3);
    signal state: state_type := s0;

begin

    process( clk, reset ) begin

        if reset = '1' then
            count <= (others => '0');
            state <= s0;
            int <= '0';
        elsif rising_edge(clk) then
            case(state) is
                when s0 =>
                    state <= s1;
                when s1 =>
                    state <= s2;
                when s2 =>
                    count <= std_logic_vector(unsigned(count)+1);
                    state <= s3;
                when s3 =>
                    if count = compare then
                        int <= '1';
                    else 
                        int <= '0';
                    end if;
                    state <= s0;
            end case;
        end if;
    end process;
                
end architecture ; -- arch
