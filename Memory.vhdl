library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity Memory is
  port (
    clock: in std_logic;
    reset: in std_logic;

    ALU_output: in std_logic_vector(31 downto 0);
    MEM_read: in std_logic;
    MEM_write: in std_logic;
    MEM_data: in std_logic_vector(31 downto 0);

    MEM_output: out std_logic_vector(31 downto 0) := (others => '0');

    in_REG_write: in std_logic;
    in_REG_write_addr: in std_logic_vector(4 downto 0);
    REG_write: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0) := (others => '0');

    BASERAM_WE: out std_logic;
    BASERAM_addr: inout std_logic_vector(19 downto 0);
    BASERAM_data: inout std_logic_vector(31 downto 0);

    EXTRAM_WE : out  STD_LOGIC; -- base ram stores data
    EXTRAM_addr: inout std_logic_vector(19 downto 0);
    EXTRAM_data: inout std_logic_vector(31 downto 0);

    DYP0: out std_logic_vector(6 downto 0) := (others => '0');
    DYP1: out std_logic_vector(6 downto 0) := (others => '0');
    LED: out std_logic_vector(15 downto 0) := (others => '0')
  ) ;
end entity ; -- Memory

architecture arch of Memory is


  component DigitalNumber port (
      clock: in std_logic;
      reset: in std_logic;
      value: in std_logic_vector(3 downto 0);
      DYP: out std_logic_vector(6 downto 0)) ;
  end component ; -- DigitalNumber

  type state_type is (s0, s1, s2, s3);
  signal state: state_type := s0;

    signal s_output: std_logic_vector(31 downto 0);
    signal s_use_me_as_output: std_logic;

    signal s_REG_write: std_logic:= '0';
    signal s_REG_write_addr: std_logic_vector(4 downto 0):= (others => '0');

    signal s_dyp_value0: std_logic_vector(3 downto 0) := (others => '0');
    signal s_dyp_value1: std_logic_vector(3 downto 0) := (others => '0');

    signal ram_choice: std_logic := '0'; -- 0: baseram
begin

  DigitalNumber0: DigitalNumber port map(clock, reset, s_dyp_value0, DYP0);
  DigitalNumber1: DigitalNumber port map(clock, reset, s_dyp_value1, DYP1);

  process(clock, reset)
  begin

    if reset = '1' then
      state <= s0;
      EXTRAM_WE <= '1'; -- disable write
      BASERAM_WE <= '1';
      EXTRAM_data <= (others => 'Z');
      BASERAM_data <= (others => 'Z');
      EXTRAM_addr <= (others => 'Z');
      BASERAM_addr <= (others => 'Z');
      MEM_output <= (others => '0');
      REG_write <= '0';
      REG_write_addr <= (others => '0');
      s_dyp_value0 <= (others => '0');
      s_dyp_value1 <= (others => '0');
      LED <= (others => '0');
    elsif rising_edge(clock) then
      case( state ) is

        when s0 =>
          EXTRAM_WE <= '1'; -- disable write
          BASERAM_WE <= '1';
          EXTRAM_data <= (others => 'Z');
          BASERAM_data <= (others => 'Z');
          EXTRAM_addr <= (others => 'Z');
          BASERAM_addr <= (others => 'Z');
          state <= s1;
      
        when s1 => -- start
          if MEM_read = '1' then 
            ram_choice <= ALU_output(20);
            if ALU_output(20) = '0' then
              BASERAM_addr <= ALU_output(19 downto 0);
            else
              BASERAM_addr <= ALU_output(19 downto 0);
            end if;
            s_use_me_as_output <= '0'; -- use ram data as output
          elsif MEM_write = '1' then
            s_output <= MEM_data;
            s_use_me_as_output <= '1';
            case( ALU_output ) is
              when x"80000000" => s_dyp_value0 <= MEM_data(3 downto 0);
              when x"80000001" => s_dyp_value1 <= MEM_data(3 downto 0);
              when x"80000002" => LED <= MEM_data(15 downto 0);
              when others => -- general
                if ALU_output(20) = '0' then
                  BASERAM_addr <= ALU_output(19 downto 0);
                  BASERAM_data <= MEM_data;
                  BASERAM_WE <= '0';
                else
                  EXTRAM_addr <= ALU_output(19 downto 0);
                  EXTRAM_data <= MEM_data;
                  EXTRAM_WE <= '0';
                end if;
            end case ;
          else
            s_output <= ALU_output;
            s_use_me_as_output <= '1';
          end if;

          state <= s2;
          s_REG_write <= in_REG_write;
          s_REG_write_addr <= in_REG_write_addr;
      
        when s2 =>
          if s_use_me_as_output = '1' then
            MEM_output <= s_output;
          else
            if ram_choice = '0' then
              MEM_output <= BASERAM_data;
            else
              MEM_output <= EXTRAM_data;
            end if;
          end if;
          EXTRAM_WE <= '1';
          BASERAM_WE <= '1';

          state <= s3;
          REG_write <= s_REG_write;
          REG_write_addr <= s_REG_write_addr;

        when s3 =>
          EXTRAM_WE <= '1'; -- disable write
          BASERAM_WE <= '1';
          EXTRAM_data <= (others => 'Z');
          BASERAM_data <= (others => 'Z');
          EXTRAM_addr <= (others => 'Z');
          BASERAM_addr <= (others => 'Z');
          state <= s0;

      end case ;
    end if;

  end process ; 

end architecture ; -- arch