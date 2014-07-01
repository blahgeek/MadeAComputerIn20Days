library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity Memory is
  port (
    clock: in std_logic;
    reset: in std_logic;

    hold_from_memory: out std_logic := '0';

    ALU_output: in std_logic_vector(31 downto 0);
    ALU_output_after_TLB: in std_logic_vector(31 downto 0);
    MEM_read: in std_logic;
    MEM_write: in std_logic;
    MEM_write_byte_only: in std_logic;
    MEM_data: in std_logic_vector(31 downto 0);

    MEM_output: out std_logic_vector(31 downto 0) := (others => '0');

    in_REG_write: in std_logic;
    in_REG_write_addr: in std_logic_vector(4 downto 0);
    in_REG_write_byte_only: in std_logic;
    REG_write: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0) := (others => '0');
    REG_write_byte_only: out std_logic := '0';
    REG_write_byte_pos: out std_logic_vector(1 downto 0) := "00";

    BASERAM_WE: out std_logic;
    BASERAM_addr: inout std_logic_vector(19 downto 0);
    BASERAM_data: inout std_logic_vector(31 downto 0);

    EXTRAM_WE : out  STD_LOGIC; -- base ram stores data
    EXTRAM_addr: inout std_logic_vector(19 downto 0);
    EXTRAM_data: inout std_logic_vector(31 downto 0);

    UART_DATA_SEND: out std_logic_vector(7 downto 0);
    UART_DATA_SEND_STB: buffer std_logic := '0';
    UART_DATA_SEND_ACK: in std_logic;

    UART_DATA_RECV: in std_logic_vector(7 downto 0);
    UART_DATA_RECV_STB: in std_logic;
    UART_DATA_RECV_ACK: out std_logic := '0';

    VGA_x: out std_logic_vector(6 downto 0);
    VGA_y: out std_logic_vector(4 downto 0);
    VGA_data: out std_logic_vector(6 downto 0);
    VGA_set: out std_logic := '0';

    ENET_D: inout std_logic_vector(15 downto 0) := (others => 'Z');
    ENET_CMD: out std_logic := '0';
    ENET_IOR : out std_logic := '1';
    ENET_IOW : out std_logic := '1';
    ENET_INT: in std_logic;

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

    signal s_use_ethernet_output: std_logic := '0';

    signal s_REG_write: std_logic:= '0';
    signal s_REG_write_addr: std_logic_vector(4 downto 0):= (others => '0');
    signal s_REG_write_byte_only: std_logic := '0';

    signal s_dyp_value0: std_logic_vector(3 downto 0) := (others => '0');
    signal s_dyp_value1: std_logic_vector(3 downto 0) := (others => '0');

    signal s_VGA_set: std_logic := '0';

    signal ram_choice: std_logic := '0'; -- 0: baseram

    signal s_MEM_data: std_logic_vector(31 downto 0);
    signal s_MEM_addr: std_logic_vector(31 downto 0);

    signal sb_in_the_middle: std_logic := '0';
    signal sb_target_data: std_logic_vector(31 downto 0);
    signal sb_replace_pos: std_logic_vector(1 downto 0);

begin

  DigitalNumber0: DigitalNumber port map(clock, reset, s_dyp_value0, DYP0);
  DigitalNumber1: DigitalNumber port map(clock, reset, s_dyp_value1, DYP1);

  process(clock, reset)
  begin

    if reset = '1' then
      state <= s0;
      hold_from_memory <= '0';
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
      UART_DATA_SEND_STB <= '0';
      UART_DATA_RECV_ACK <= '0';
      VGA_set <= '0';
      s_VGA_set <= '0';
      ENET_D <= (others => 'Z');
      ENET_CMD <= '0';
      ENET_IOR <= '1';
      ENET_IOW <= '1';
      sb_in_the_middle <= '0';
      s_use_ethernet_output <= '0';
    elsif rising_edge(clock) then
      case( state ) is

        when s0 =>
          EXTRAM_WE <= '1'; -- disable write
          BASERAM_WE <= '1';
          EXTRAM_data <= (others => 'Z');
          BASERAM_data <= (others => 'Z');
          EXTRAM_addr <= (others => 'Z');
          BASERAM_addr <= (others => 'Z');
          if UART_DATA_SEND_ACK = '1' then 
            UART_DATA_SEND_STB <= '0';
          end if;
          UART_DATA_RECV_ACK <= '0';
          VGA_set <= '0';
          ENET_D <= (others => 'Z');
          ENET_IOR <= '1';
          ENET_IOW <= '1';
          s_use_ethernet_output <= '0';
          if sb_in_the_middle = '1' then
            s_MEM_data <= sb_target_data;
            -- s_MEM_addr remains unchange
          else
            s_MEM_data <= MEM_data;
            s_MEM_addr <= ALU_output_after_TLB;
          end if;
          hold_from_memory <= '0';
          state <= s1;
      
        when s1 => -- start
          if MEM_read = '1' or (MEM_write = '1' and MEM_write_byte_only = '1' and sb_in_the_middle = '0') then 
            if MEM_write = '1' then -- sb!!!
              sb_in_the_middle <= '1';
              hold_from_memory <= '1'; -- hold it!
              sb_replace_pos <= s_MEM_addr(1 downto 0);
            end if;
            case(s_MEM_addr(27 downto 0)) is
              when x"FD003FC" => -- uart control
                s_use_me_as_output <= '1';
                s_output(31 downto 2) <= (others => '0');
                s_output(1) <= UART_DATA_RECV_STB; -- can read
                s_output(0) <= not UART_DATA_SEND_STB; -- can write
              when x"FD003F8" => -- uart
                s_use_me_as_output <= '1';
                s_output(31 downto 8) <= (others => '0');
                s_output(7 downto 0) <= UART_DATA_RECV;
                UART_DATA_RECV_ACK <= '1';
              when x"FD00018" | x"FD0001C" => -- ethernet!
                ENET_CMD <= s_MEM_addr(2); -- CMD = 1 if FD0000C which is data
                ENET_IOR <= '0'; -- read!
                s_use_me_as_output <= '0';
                s_use_ethernet_output <= '1';
              when x"FD00014" =>
                s_use_me_as_output <= '1';
                s_output(31 downto 1) <= (others => '0');
                s_output(0) <= ENET_INT;
              when others =>
                ram_choice <= s_MEM_addr(22);
                if s_MEM_addr(22) = '0' then
                  BASERAM_addr <= s_MEM_addr(21 downto 2);
                else
                  EXTRAM_addr <= s_MEM_addr(21 downto 2);
                end if;
                s_use_me_as_output <= '0'; -- use ram data as output
              end case;
          elsif MEM_write = '1' or sb_in_the_middle = '1' then
            sb_in_the_middle <= '0';
            s_output <= s_MEM_data;
            s_use_me_as_output <= '1';
            if s_MEM_addr(29 downto 28) = "11" then
              VGA_data <= s_MEM_data(6 downto 0);
              VGA_x <= s_MEM_addr(14 downto 8);
              VGA_y <= s_MEM_addr(4 downto 0);
              s_VGA_set <= '1';
            else
              s_VGA_set <= '0';
              case( s_MEM_addr(27 downto 0) ) is
                when x"FD00000" => s_dyp_value0 <= s_MEM_data(3 downto 0);
                when x"FD00004" => s_dyp_value1 <= s_MEM_data(3 downto 0);
                when x"FD00008" => LED <= s_MEM_data(15 downto 0);
                when x"FD003F8" =>
                  UART_DATA_SEND <= s_MEM_data(7 downto 0);
                  UART_DATA_SEND_STB <= '1';
                when x"FD00018" | x"FD0001C" => -- ethernet!
                  ENET_CMD <= s_MEM_addr(2); -- CMD = 1 if FD0000C which is data
                  ENET_IOW <= '0'; -- write!
                  ENET_D <= s_MEM_data(15 downto 0);
                when others => -- general
                  if s_MEM_addr(22) = '0' then
                    BASERAM_addr <= s_MEM_addr(21 downto 2);
                    BASERAM_data <= s_MEM_data;
                    BASERAM_WE <= '0';
                  else
                    EXTRAM_addr <= s_MEM_addr(21 downto 2);
                    EXTRAM_data <= s_MEM_data;
                    EXTRAM_WE <= '0';
                  end if;
              end case ;
            end if;
          else
            s_output <= ALU_output;
            s_use_me_as_output <= '1';
          end if;

          state <= s2;
          s_REG_write <= in_REG_write;
          s_REG_write_addr <= in_REG_write_addr;
          s_REG_write_byte_only <= in_REG_write_byte_only;
      
        when s2 =>
          VGA_set <= s_VGA_set;
          if s_use_me_as_output = '1' then
            MEM_output <= s_output;
            if sb_in_the_middle = '1' then
              sb_target_data <= s_output;
            end if;
          elsif s_use_ethernet_output = '1' then
            MEM_output(31 downto 16) <= (others => '0');
            MEM_output(15 downto 0) <= ENET_D;
            if sb_in_the_middle = '1' then
              sb_target_data(31 downto 16) <= (others => '0');
              sb_target_data(15 downto 0) <= ENET_D;
            end if;
          else
            if ram_choice = '0' then
              MEM_output <= BASERAM_data;
              if sb_in_the_middle = '1' then
                sb_target_data <= BASERAM_data;
              end if;
            else
              MEM_output <= EXTRAM_data;
              if sb_in_the_middle = '1' then
                sb_target_data <= EXTRAM_data;
              end if;
            end if;
          end if;
          EXTRAM_WE <= '1';
          BASERAM_WE <= '1';
          if UART_DATA_SEND_ACK = '1' then 
            UART_DATA_SEND_STB <= '0';
          end if;
          ENET_IOR <= '1';
          ENET_IOW <= '1';

          state <= s3;
          REG_write <= s_REG_write;
          REG_write_addr <= s_REG_write_addr;
          REG_write_byte_only <= s_REG_write_byte_only;
          REG_write_byte_pos <= s_MEM_addr(1 downto 0);

        when s3 =>

          if sb_in_the_middle = '1' then
            if sb_replace_pos = "11" then
              sb_target_data(7 downto 0) <= s_MEM_data(7 downto 0);
            elsif sb_replace_pos = "10" then
              sb_target_data(15 downto 8) <= s_MEM_data(7 downto 0);
            elsif sb_replace_pos = "01" then
              sb_target_data(23 downto 16) <= s_MEM_data(7 downto 0);
            else
              sb_target_data(31 downto 24) <= s_MEM_data(7 downto 0);
            end if;
          end if;
                
          EXTRAM_WE <= '1'; -- disable write
          BASERAM_WE <= '1';
          EXTRAM_data <= (others => 'Z');
          BASERAM_data <= (others => 'Z');
          EXTRAM_addr <= (others => 'Z');
          BASERAM_addr <= (others => 'Z');
          if UART_DATA_SEND_ACK = '1' then 
            UART_DATA_SEND_STB <= '0';
          end if;
          ENET_D <= (others => 'Z');
          state <= s0;

      end case ;
    end if;

  end process ; 

end architecture ; -- arch
