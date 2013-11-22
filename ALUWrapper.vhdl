library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity ALUWrapper is
  port (
    clock: in std_logic;
    reset: in std_logic;

    ALU_operator: in std_logic_vector(3 downto 0) ;
    ALU_numA: in std_logic_vector(31 downto 0) ;
    ALU_numB: in std_logic_vector(31 downto 0) ;

    ALU_output: out std_logic_vector(31 downto 0) := (others => '0');

    in_MEM_read: in std_logic ;
    in_MEM_write: in std_logic ;
    in_MEM_data: in std_logic_vector(31 downto 0);
    in_REG_write: in std_logic ;
    in_REG_write_addr: in std_logic_vector(4 downto 0);

    MEM_read: out std_logic := '0';
    MEM_write: out std_logic := '0';
    MEM_data: out std_logic_vector(31 downto 0);
    REG_write: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0)
  ) ;
end entity ; -- ALUWrapper

architecture arch of ALUWrapper is

component ALU 
    Port (  A: in STD_LOGIC_VECTOR(31 downto 0);
            B: in STD_LOGIC_VECTOR(31 downto 0);
            op: in STD_LOGIC_VECTOR(3 downto 0);
            result: out STD_LOGIC_VECTOR(31 downto 0)
        );
end component;

    signal a, b, c: std_logic_vector(31 downto 0) := (others => '0');
    signal op: std_logic_vector(3 downto 0);

    type state_type is (s0, s1, s2, s3);
    signal state: state_type := s0;

    signal s_MEM_read: std_logic := '0';
    signal s_MEM_write: std_logic := '0';
    signal s_MEM_data: std_logic_vector(31 downto 0);
    signal s_REG_write: std_logic := '0';
    signal s_REG_write_addr: std_logic_vector(4 downto 0);

begin

    alu0: ALU port map(a, b, op, c);

    process(clock, reset) begin
        if reset = '1' then 
            state <= s0;

            MEM_read <= '0';
            MEM_write <= '0';
            REG_write <= '0';
            ALU_output <= (others => '0');

        elsif rising_edge(clock) then
            case( state ) is
            
                when s0 =>
                    a <= ALU_numA;
                    b <= ALU_numB;
                    op <= ALU_operator;
                    s_MEM_write <= in_MEM_write;
                    s_MEM_read <= in_MEM_read;
                    s_MEM_data <= in_MEM_data;
                    s_REG_write <= in_REG_write;
                    s_REG_write_addr <= in_REG_write_addr;

                    state <= s1;

                when s1 => state <= s2;
                when s2 => state <= s3;
            
                when s3 =>

                    ALU_output <= c;
                    MEM_write <= s_MEM_write;
                    MEM_read <= s_MEM_read;
                    MEM_data <= s_MEM_data;
                    REG_write <= s_REG_write;
                    REG_write_addr <= s_REG_write_addr;

                    state <= s0;
            
            end case ;
        end if;
    end process;

end architecture ; -- arch

