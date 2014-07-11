library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity ALUTestbench is
end entity ; -- ALUTestbench

architecture arch of ALUTestbench is

component ALU 
    Port (  A: in STD_LOGIC_VECTOR(31 downto 0);
            B: in STD_LOGIC_VECTOR(31 downto 0);
            op: in STD_LOGIC_VECTOR(3 downto 0);
            result: out STD_LOGIC_VECTOR(31 downto 0)
        );
end component;

    signal a, b, c: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
    signal op: STD_LOGIC_VECTOR(3 downto 0) := "1111";

  constant clk_period :time :=20 ns;

begin

    alu0: ALU port map (a, b, op, c);

    process begin
        a <= x"ffffffff";
        b <= x"00000004";
        op <= "0000";
        wait for clk_period;
        op <= "0001";
        wait for clk_period;
        op <= "0010";
        wait for clk_period;
        op <= "0011";
        wait for clk_period;
        op <= "0100";
        wait for clk_period;
        op <= "0101";
        wait for clk_period;
        op <= "0110";
        wait for clk_period;
        op <= "0111";
        wait for clk_period;
        op <= "1000";
        wait for clk_period;
        op <= "1001";
        wait for clk_period;
        op <= "1010";
        wait for clk_period;
        op <= "1011";
        wait for clk_period;
        op <= "1100";
        wait for clk_period;
        op <= "1101";
        wait for clk_period;
        op <= "1110";
        wait for clk_period;
        op <= "1111";
        wait for clk_period;
        wait;
    end process;

end architecture ; -- arch