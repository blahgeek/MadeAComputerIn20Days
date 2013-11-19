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
    ALU_numB_forward: out std_logic_vector(31 downto 0) := (others => '0');

    -- forward
    in_JUMP_true: in std_logic; 
    in_JUMP_use_alu: in std_logic; 
    in_JUMP_true_if_alu_out_true: in std_logic; 
    in_JUMP_addr: in std_logic_vector(31 downto 0); 
    in_MEM_read: in std_logic ;
    in_MEM_write: in std_logic ;
    in_MEM_addr_or_data: in std_logic_vector(31 downto 0);
    in_MEM_use_aluout_as_addr: in std_logic;
    in_REG_write: in std_logic ;
    in_REG_write_addr: in std_logic_vector(4 downto 0);

    JUMP_true: out std_logic := '0'; 
    JUMP_use_alu: out std_logic; 
    JUMP_true_if_alu_out_true: out std_logic := '0'; 
    JUMP_addr: out std_logic_vector(31 downto 0); 
    MEM_read: out std_logic := '0';
    MEM_write: out std_logic := '0';
    MEM_addr_or_data: out std_logic_vector(31 downto 0);
    MEM_use_aluout_as_addr: out std_logic;
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

    signal state: std_logic := '0';

    signal s_JUMP_true: std_logic := '0'; 
    signal s_JUMP_use_alu: std_logic; 
    signal s_JUMP_true_if_alu_out_true: std_logic := '0'; 
    signal s_JUMP_addr: std_logic_vector(31 downto 0); 
    signal s_MEM_read: std_logic := '0';
    signal s_MEM_write: std_logic := '0';
    signal s_MEM_addr_or_data: std_logic_vector(31 downto 0);
    signal s_MEM_use_aluout_as_addr: std_logic;
    signal s_REG_write: std_logic := '0';
    signal s_REG_write_addr: std_logic_vector(4 downto 0);

begin

    alu0: ALU port map(a, b, op, c);

    process(clock, reset) begin
        if reset = '1' then 
            state <= '0';

            JUMP_true <= '0';
            JUMP_true_if_alu_out_true <= '0';
            MEM_read <= '0';
            MEM_write <= '0';
            REG_write <= '0';
            ALU_output <= (others => '0');
            ALU_numB_forward <= (others => '0');

        elsif rising_edge(clock) then
            case( state ) is
            
                when '0' =>
                    a <= ALU_numA;
                    b <= ALU_numB;
                    op <= ALU_operator;
                    s_JUMP_true <= in_JUMP_true;
                    s_JUMP_addr <= in_JUMP_addr;
                    s_JUMP_use_alu <= in_JUMP_use_alu;
                    s_JUMP_true_if_alu_out_true <= in_JUMP_true_if_alu_out_true;
                    s_MEM_write <= in_MEM_write;
                    s_MEM_read <= in_MEM_read;
                    s_MEM_addr_or_data <= in_MEM_addr_or_data;
                    s_MEM_use_aluout_as_addr <= in_MEM_use_aluout_as_addr;
                    s_REG_write <= in_REG_write;
                    s_REG_write_addr <= in_REG_write_addr;

                    state <= '1';
            
                when others =>

                    ALU_output <= c;
                    ALU_numB_forward <= b;
                    JUMP_true <= s_JUMP_true;
                    JUMP_addr <= s_JUMP_addr;
                    JUMP_use_alu <= s_JUMP_use_alu;
                    JUMP_true_if_alu_out_true <= s_JUMP_true_if_alu_out_true;
                    MEM_write <= s_MEM_write;
                    MEM_read <= s_MEM_read;
                    MEM_addr_or_data <= s_MEM_addr_or_data;
                    MEM_use_aluout_as_addr <= s_MEM_use_aluout_as_addr;
                    REG_write <= s_REG_write;
                    REG_write_addr <= s_REG_write_addr;

                    state <= '0';
            
            end case ;
        end if;
    end process;

end architecture ; -- arch

