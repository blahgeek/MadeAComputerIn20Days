library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity PCdecider is
  port (
    clock: in std_logic;
    reset: in std_logic;

    JUMP_true: in std_logic;
    JUMP_use_alu: in std_logic;
    JUMP_true_if_alu_out_true: in std_logic;
    JUMP_addr: in std_logic_vector(31 downto 0);

    ALU_output: in std_logic_vector(31 downto 0);

    PC: out std_logic_vector(31 downto 0)
  ) ;
end entity ; -- PCdecider

architecture arch of PCdecider is

    constant BEGIN_PC: std_logic_vector(31 downto 0) := (others => '0');
    signal state: std_logic := '0';
    signal s_pc: std_logic_vector(31 downto 0) := BEGIN_PC;

begin

  process(clock, reset)
  begin
    if reset = '1' then
      state <= '0';
      PC <= BEGIN_PC;
    elsif rising_edge(clock) then
      case( state ) is
      
        when '0' =>
          if JUMP_true = '1' or 
              (JUMP_true_if_alu_out_true = '1' 
                and ALU_output(0) = '1') then -- jump!
            if JUMP_use_alu = '1' then
              s_pc <= ALU_output;
            else
              s_pc <= JUMP_addr;
            end if;
          else
            s_pc <= std_logic_vector(unsigned(s_pc)+4);
          end if;

          state <= '1';
      
        when others =>
          PC <= s_pc;

          state <= '0';
      
      end case ;
    end if;
  end process;

end architecture ; -- arch