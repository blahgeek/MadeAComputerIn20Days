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

    TLB_virt: out std_logic_vector(19 downto 0);
    TLB_real: in std_logic_vector(19 downto 0);
    RAM_select: out std_logic := '0';

    PC: buffer std_logic_vector(31 downto 0)
  ) ;
end entity ; -- PCdecider

architecture arch of PCdecider is

    constant BEGIN_PC: std_logic_vector(31 downto 0) := x"80000000";

  type state_type is (s0, s1, s2, s3);
  signal state: state_type := s0;

    signal s_pc: std_logic_vector(31 downto 0) := BEGIN_PC;
    signal real_addr: std_logic_vector(31 downto 0) := (others => '0');
    signal s_addr: std_logic_vector(19 downto 0):= (others => '0');

begin

  process(clock, reset)
  begin
    if reset = '1' then
      state <= s0;
      s_pc <= BEGIN_PC;
      PC <= (others => '0');
      BASERAM_addr <= (others => '0');
      EXTRAM_addr <= (others => '0');
      RAM_select <= '0';
      s_addr <= (others => '0');
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
          TLB_virt <= s_pc(31 downto 12);
          BASERAM_addr <= (others => 'Z');
          EXTRAM_addr <= (others => 'Z');
          state <= s2;

        when s2 =>
          real_addr(31 downto 12) <= TLB_real;
          real_addr(11 downto 0) <= s_pc(11 downto 0);
          state <= s3;
      
        when s3 =>
          if hold = '1' then
            BASERAM_addr <= s_addr;
            EXTRAM_addr <= s_addr;
          else
            PC <= s_pc;
            RAM_select <= real_addr(22);
            BASERAM_addr <= real_addr(21 downto 2);
            EXTRAM_addr <= real_addr(21 downto 2);
            s_addr <= real_addr(21 downto 2);
          end if;

          state <= s0;
      
      end case ;
    end if;
  end process;

end architecture ; -- arch