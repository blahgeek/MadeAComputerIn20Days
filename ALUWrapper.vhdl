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
    ALU_output_after_TLB: out std_logic_vector(31 downto 0) := (others => '0');

    TLB_virt: out std_logic_vector(19 downto 0);
    TLB_real: in std_logic_vector(19 downto 0);
    TLB_bad: in std_logic;

    TLB_exception: out std_logic:= '0';
    TLB_exception_read_or_write: out std_logic:= '0'; -- 0 for read

    in_MEM_read: in std_logic ;
    in_MEM_write: in std_logic ;
    in_MEM_data: in std_logic_vector(31 downto 0);
    in_REG_write: in std_logic ;
    in_REG_write_byte_only: in std_logic;
    in_REG_write_addr: in std_logic_vector(4 downto 0);

    MEM_read: out std_logic := '0';
    MEM_write: out std_logic := '0';
    MEM_data: out std_logic_vector(31 downto 0);
    REG_write: out std_logic := '0';
    REG_write_byte_only: out std_logic := '0';
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
    signal s_REG_write_byte_only: std_logic := '0';
    signal s_REG_write_addr: std_logic_vector(4 downto 0);
    signal s_skip_one: std_logic:= '0';

begin

    alu0: ALU port map(a, b, op, c);

    process(clock, reset) begin
        if reset = '1' then 
            state <= s0;

            MEM_read <= '0';
            MEM_write <= '0';
            REG_write <= '0';
            ALU_output <= (others => '0');
            s_skip_one <= '0';
            TLB_exception <= '0';

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
                    s_REG_write_byte_only <= in_REG_write_byte_only;
                    s_REG_write_addr <= in_REG_write_addr;

                    state <= s1;

                when s1 =>
                    TLB_virt <= c(31 downto 12);
                    state <= s2;

                when s2 => state <= s3;
            
                when s3 =>

                    if s_skip_one = '1' then
                        MEM_read <= '0';
                        MEM_write <= '0';
                        REG_write <= '0';
                        ALU_output <= (others => '0');
                        TLB_exception <= '0';
                        s_skip_one <= '0';
                    else
                        if TLB_bad = '1' and (s_MEM_write = '1' or s_MEM_read = '1') then
                            MEM_read <= '0';
                            MEM_write <= '0';
                            REG_write <= '0';
                            ALU_output <= (others => '0');
                            s_skip_one <= '1'; -- skip next
                            TLB_exception <= '1';
                            if s_MEM_read = '1' then 
                                TLB_exception_read_or_write <= '0';
                            else
                                TLB_exception_read_or_write <= '1';
                            end if;
                        else
                            ALU_output <= c;
                            ALU_output_after_TLB(31 downto 12) <= TLB_real;
                            ALU_output_after_TLB(11 downto 0) <= c(11 downto 0);
                            MEM_write <= s_MEM_write;
                            MEM_read <= s_MEM_read;
                            MEM_data <= s_MEM_data;
                            REG_write <= s_REG_write;
                            REG_write_byte_only <= s_REG_write_byte_only;
                            REG_write_addr <= s_REG_write_addr;
                            TLB_exception <= '0';
                        end if;
                    end if;

                    state <= s0;
            
            end case ;
        end if;
    end process;

end architecture ; -- arch

