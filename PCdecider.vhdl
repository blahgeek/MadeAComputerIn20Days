library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity PCdecider is
  port (
    clock: in std_logic;
    reset: in std_logic;

    hold: in std_logic;

    JUMP_true: in std_logic;
    JUMP_addr: in std_logic_vector(31 downto 0);

    BASERAM_addr: inout std_logic_vector(19 downto 0);
    EXTRAM_addr: inout std_logic_vector(19 downto 0);

    PC: buffer std_logic_vector(31 downto 0)
  ) ;
end entity ; -- PCdecider

architecture arch of PCdecider is

    constant BEGIN_PC: std_logic_vector(31 downto 0) := (others => '0');

  type state_type is (s0, s1, s2, s3);
  signal state: state_type := s0;

    signal s_pc: std_logic_vector(31 downto 0) := BEGIN_PC;

begin

  process(clock, reset)
  begin
    if reset = '1' then
      state <= s0;
      s_pc <= BEGIN_PC;
      PC <= BEGIN_PC;
      BASERAM_addr <= (others => '0');
      EXTRAM_addr <= (others => '0');
    elsif rising_edge(clock) then
      case( state ) is
      
        when s0 =>
          if hold = '0' then 
            if JUMP_true = '1' then -- jump!
              s_pc <= JUMP_addr;
            else
              s_pc <= std_logic_vector(unsigned(s_pc)+4);
            end if;
          end if;

          state <= s1;

        when s1 =>
          BASERAM_addr <= (others => 'Z');
          EXTRAM_addr <= (others => 'Z');
          state <= s2;
        when s2 =>
          state <= s3;
      
        when s3 =>
          if hold = '1' then
            BASERAM_addr <= PC(21 downto 2);
            EXTRAM_addr <= PC(21 downto 2);
          else
            PC <= s_pc;
            BASERAM_addr <= s_pc(21 downto 2);
            EXTRAM_addr <= s_pc(21 downto 2);
          end if;

          state <= s0;
      
      end case ;
    end if;
  end process;

end architecture ; -- arch