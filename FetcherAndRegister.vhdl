library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity FetcherAndRegister is
  port (
    PC: in std_logic_vector(31 downto 0);
    clock: in std_logic;
    reset: in std_logic;

    -- signals from 5th stage, for writing registers
    BACK_REG_write: in std_logic;
    BACK_REG_write_addr: in std_logic_vector(4 downto 0);
    BACK_REG_write_data: in std_logic_vector(31 downto 0);

    BASERAM_data: in std_logic_vector(31 downto 0);
    EXTRAM_data: in std_logic_vector(31 downto 0);

    -- output signals
    ALU_operator: out std_logic_vector(3 downto 0) := "1111";
    ALU_numA: out std_logic_vector(31 downto 0) := (others => '0');
    ALU_numB: out std_logic_vector(31 downto 0) := (others => '0');

    JUMP_true: out std_logic := '0'; -- if 1: JUMP!
    JUMP_addr: out std_logic_vector(31 downto 0); -- jump address if JUMP_use_alu is 0

    MEM_read: out std_logic := '0'; -- read memory
    MEM_write: out std_logic := '0'; -- write memory
    MEM_data: out std_logic_vector(31 downto 0);
    -- use ALUout as addr

    REG_write: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0)  -- we have 32 registers
  ) ;
 end entity ; -- FetcherAndRegister 


 architecture arch of FetcherAndRegister is

 component Registers
   port (
    clk: in std_logic;
    reset: in std_logic;
    RegReadNumberA: in std_logic_vector(4 downto 0);
    RegReadNumberB: in std_logic_vector(4 downto 0);
    RegWrite: in std_logic;
    RegWriteNumber: in std_logic_vector(4 downto 0);
    RegWriteValue: in std_logic_vector(31 downto 0);
    RegReadValueA: out std_logic_vector(31 downto 0);
    RegReadValueB: out std_logic_vector(31 downto 0));
 end component;

  type state_type is (s0, s1, s2, s3);
  signal state: state_type := s0;

  signal s_REG_clock: std_logic := '0';
  signal s_REG_write: std_logic;
  signal s_REG_read_number_B: std_logic_vector(4 downto 0) := (others => '0');
  signal s_REG_read_value_B: std_logic_vector(31 downto 0);
  signal s_REG_read_number_A, s_REG_write_number: std_logic_vector(4 downto 0) := (others => '0');
  signal s_REG_read_value_A, s_REG_write_value: std_logic_vector(31 downto 0);


  signal outbuffer_ALU_operator: std_logic_vector(3 downto 0) := "1111";
  signal outbuffer_ALU_numA: std_logic_vector(31 downto 0) := (others => '0');
  signal outbuffer_ALU_numB: std_logic_vector(31 downto 0) := (others => '0');

  signal outbuffer_JUMP_true: std_logic := '0';
  signal outbuffer_JUMP_addr: std_logic_vector(31 downto 0);

  signal outbuffer_MEM_read: std_logic := '0';
  signal outbuffer_MEM_write: std_logic := '0';
  signal outbuffer_MEM_data: std_logic_vector(31 downto 0);

  signal outbuffer_REG_write: std_logic := '0';
  signal outbuffer_REG_write_addr: std_logic_vector(4 downto 0);

  signal immediate_sign_extend, immediate_zero_extend: std_logic_vector(31 downto 0);

  signal numA_from_reg, numB_from_reg: std_logic; -- if read register for ALU
  signal mem_data_from_reg_B: std_logic;

  signal s_jump_true_if_eq: std_logic := '0';
  signal s_jump_true_if_ne: std_logic := '0';
  signal s_jump_addr_from_reg_a: std_logic := '0';

  signal s_data : std_logic_vector(31 downto 0):= (others => '0');

begin

  with PC(22) select
    s_data <= BASERAM_data when '0',
              EXTRAM_data when others;

  REG0: Registers port map(s_REG_clock, reset, s_REG_read_number_A, s_REG_read_number_B,
                          s_REG_write, s_REG_write_number, 
                          s_REG_write_value, s_REG_read_value_A, s_REG_read_value_B);

  -- always compute immediate extend
  immediate_zero_extend(15 downto 0) <= s_data(15 downto 0);
  immediate_zero_extend(31 downto 16) <= (others => '0');
  immediate_sign_extend(15 downto 0) <= s_data(15 downto 0);
  immediate_sign_extend(31 downto 16) <= (others => s_data(15));

  s_REG_clock <= reset or (not clock); -- reverse

  process(clock, reset)
  begin
    if reset = '1' then
      state <= s0;
      ALU_operator <= "1111";
      ALU_numA <= (others => '0');
      ALU_numB <= (others => '0');
      JUMP_true <= '0';
      MEM_read <= '0';
      MEM_write <= '0';
      REG_write <= '0';

    elsif rising_edge(clock) then

      case( state ) is
      
        when s0 => -- state: read instruction
          
          if s_data(31 downto 26) = "000000" then -- R type
            s_jump_true_if_ne <= '0';
            s_jump_true_if_eq <= '0';

            if s_data(5) = '1' then -- 3 reg type
              numA_from_reg <= '1';
              s_REG_read_number_A <= s_data(25 downto 21); -- rs
              numB_from_reg <= '1';
              s_REG_read_number_B <= s_data(20 downto 16); -- rt
              outbuffer_JUMP_true <= '0';
              outbuffer_MEM_read <= '0';
              outbuffer_MEM_write <= '0';
              outbuffer_REG_write <= '1';
              outbuffer_REG_write_addr <= s_data(15 downto 11); -- rd
              outbuffer_ALU_operator <= s_data(3 downto 0);
            else
              if s_data(2) = '1' then -- also 3 reg type
                -- yes, rs and rt is swapped
                numB_from_reg <= '1';
                s_REG_read_number_B <= s_data(25 downto 21); -- rs
                numA_from_reg <= '1';
                s_REG_read_number_A <= s_data(20 downto 16); -- rt
                outbuffer_JUMP_true <= '0';
                outbuffer_MEM_read <= '0';
                outbuffer_MEM_write <= '0';
                outbuffer_REG_write <= '1';
                outbuffer_REG_write_addr <= s_data(15 downto 11); -- rd
                case( s_data(1 downto 0) ) is
                  when "00" => outbuffer_ALU_operator <= "1100"; -- C, "<<"
                  when "10" => outbuffer_ALU_operator <= "1101"; -- D, >>, logical
                  when "11" => outbuffer_ALU_operator <= "1110"; -- E, >>, arithmetic
                  when others => outbuffer_ALU_operator <= "1111"; -- do nothing
                end case ;
              else
                if s_data(3) = '0' then  -- not jr
                  numA_from_reg <= '1';
                  s_REG_read_number_A <= s_data(20 downto 16); -- rt
                  numB_from_reg <= '0'; -- B is immediate
                  outbuffer_ALU_numB(4 downto 0) <= s_data(10 downto 6);
                  outbuffer_ALU_numB(31 downto 5) <= (others => '0');
                  outbuffer_JUMP_true <= '0';
                  outbuffer_MEM_read <= '0';
                  outbuffer_MEM_write <= '0';
                  outbuffer_REG_write <= '1';
                  outbuffer_REG_write_addr <= s_data(15 downto 11); -- rd
                  case( s_data(1 downto 0) ) is
                    when "00" => outbuffer_ALU_operator <= "1100"; -- C, "<<"
                    when "10" => outbuffer_ALU_operator <= "1101"; -- D, >>, logical
                    when "11" => outbuffer_ALU_operator <= "1110"; -- E, >>, arithmetic
                    when others => outbuffer_ALU_operator <= "1111"; -- do nothing
                  end case ;
                else -- jr
                  numA_from_reg <= '1';
                  s_REG_read_number_A <= s_data(25 downto 21); -- rs
                  numB_from_reg <= '0';
                  outbuffer_JUMP_true <= '1'; -- jump
                  s_jump_addr_from_reg_a <= '1';
                  outbuffer_MEM_read <= '0';
                  outbuffer_MEM_write <= '0';
                  outbuffer_REG_write <= '0';
                  outbuffer_ALU_operator <= "1111"; -- do nothing, forward A
                end if;
              end if;
            end if;

          elsif s_data(31 downto 28) = "0000" then -- J type
            s_jump_true_if_ne <= '0';
            s_jump_true_if_eq <= '0';
            s_jump_addr_from_reg_a <= '0';
            outbuffer_ALU_numA <= PC;
            numB_from_reg <= '0';
            outbuffer_ALU_numB(3 downto 0) <= "1000"; -- 8
            outbuffer_ALU_numB(31 downto 4) <= (others=>'0');
            outbuffer_ALU_operator <= "0001"; -- output PC+8
            outbuffer_JUMP_true <= '1'; -- jump
            outbuffer_JUMP_addr(31 downto 28) <= PC(31 downto 28); -- this is wrong but it should be OK in our machine
            outbuffer_JUMP_addr(27 downto 2) <= s_data(25 downto 0);
            outbuffer_JUMP_addr(1 downto 0) <= "00";
            outbuffer_MEM_write <= '0';
            outbuffer_MEM_read <= '0';
            if s_data(27 downto 26) = "10" then -- j
              outbuffer_REG_write <= '0';
            else -- jal
              outbuffer_REG_write <= '1';
              outbuffer_REG_write_addr <= "11111"; -- write to R31
            end if;

          else -- I type
            if s_data(31 downto 30) = "10" then -- lw or sw
              numA_from_reg <= '1';
              s_REG_read_number_A <= s_data(25 downto 21);
              numB_from_reg <= '0';
              outbuffer_ALU_numB <= immediate_sign_extend;
              outbuffer_ALU_operator <= "0001"; -- add
              outbuffer_JUMP_true <= '0';
              s_jump_true_if_eq <= '0';
              s_jump_true_if_ne <= '0';
              if s_data(29 downto 26) = "0011" then  -- lw
                outbuffer_MEM_read <= '1'; -- read memory!
                outbuffer_MEM_write <= '0';
                outbuffer_REG_write <= '1';
                outbuffer_REG_write_addr <= s_data(20 downto 16);
              else  -- sw
                outbuffer_MEM_read <= '0';
                outbuffer_MEM_write <= '1'; -- write memory!
                mem_data_from_reg_B <= '1'; -- read reg B to mem_addr_or_data_from_reg_B
                s_REG_read_number_B <= s_data(20 downto 16);
                outbuffer_REG_write <= '0'; -- not write register
              end if;
            elsif s_data(31 downto 26) = "001111" then -- lui
              numA_from_reg <= '0';
              outbuffer_ALU_numA(31 downto 16) <= s_data(15 downto 0);
              outbuffer_ALU_numA(15 downto 0) <= (others => '0');
              numB_from_reg <= '0';
              outbuffer_ALU_operator <= "1111"; -- forward A
              outbuffer_JUMP_true <= '0';
              s_jump_true_if_ne <= '0';
              s_jump_true_if_eq <= '0';
              outbuffer_MEM_write <= '0';
              outbuffer_MEM_read <= '0';
              outbuffer_REG_write <= '1';
              outbuffer_REG_write_addr <= s_data(20 downto 16);
            elsif s_data(31 downto 29) = "000" then -- branch
              numA_from_reg <= '1';
              s_REG_read_number_A <= s_data(25 downto 21);
              numB_from_reg <= '1';
              s_REG_read_number_B <= s_data(20 downto 16);
              outbuffer_ALU_operator <= "1111";
              outbuffer_JUMP_true <= '0';
              s_jump_addr_from_reg_a <= '0';
              outbuffer_JUMP_addr(31 downto 2) <= std_logic_vector(
                      signed(PC(31 downto 2))+
                      signed(s_data(15 downto 0))+1);
              outbuffer_JUMP_addr(1 downto 0) <= "00";
              outbuffer_MEM_read <= '0';
              outbuffer_MEM_write <= '0';
              outbuffer_REG_write <= '0';
              if s_data(28 downto 26) = "100" then -- beq
                s_jump_true_if_eq <= '1';
                s_jump_true_if_ne <= '0';
              else -- bne
                s_jump_true_if_eq <= '0';
                s_jump_true_if_ne <= '1';
              end if;
            else -- other I type
              numA_from_reg <= '1';
              s_REG_read_number_A <= s_data(25 downto 21);
              numB_from_reg <= '0';
              outbuffer_JUMP_true <= '0';
              s_jump_true_if_ne <= '0';
              s_jump_true_if_eq <= '0';
              outbuffer_MEM_write <= '0';
              outbuffer_MEM_read <= '0';
              outbuffer_REG_write <= '1';
              outbuffer_REG_write_addr <= s_data(20 downto 16);
              case( s_data(29 downto 26) ) is
                when "1000" => -- addi
                  outbuffer_ALU_numB <= immediate_sign_extend;
                  outbuffer_ALU_operator <= "0000";
                when "1001" => -- addiu
                  outbuffer_ALU_numB <= immediate_zero_extend;
                  outbuffer_ALU_operator <= "0001";
                when "1100" => -- andi
                  outbuffer_ALU_numB <= immediate_zero_extend;
                  outbuffer_ALU_operator <= "0100";
                when "1101" => --ori
                  outbuffer_ALU_numB <= immediate_zero_extend;
                  outbuffer_ALU_operator <= "0101";
                when "1110" => -- xori
                  outbuffer_ALU_numB <= immediate_zero_extend;
                  outbuffer_ALU_operator <= "0110";
                when "1010" => --slti
                  outbuffer_ALU_numB <= immediate_sign_extend;
                  outbuffer_ALU_operator <= "1010";
                when "1011" => -- sltiu
                  outbuffer_ALU_numB <= immediate_zero_extend;
                  outbuffer_ALU_operator <= "1011";
                when others => -- wtf
                  outbuffer_ALU_numB <= immediate_zero_extend;
                  outbuffer_ALU_operator <= "1111";
              end case ;
            end if;

          end if;

          s_REG_write <= BACK_REG_write;
          s_REG_write_number <= BACK_REG_write_addr;
          s_REG_write_value <= BACK_REG_write_data;

          state <= s1;

        when s1 => state <= s2;
        when s2 => state <= s3;
      
        when s3 =>  -- state: now we got data from register

          if numA_from_reg = '1' then 
            ALU_numA <= s_REG_read_value_A;
          else
            ALU_numA <= outbuffer_ALU_numA;
          end if;
          if numB_from_reg = '1' then
            ALU_numB <= s_REG_read_value_B;
          else
            ALU_numB <= outbuffer_ALU_numB;
          end if;

          if mem_data_from_reg_B = '1' then
            MEM_data <= s_REG_read_value_B;
          else
            MEM_data <= outbuffer_MEM_data;
          end if;

          if s_jump_addr_from_reg_a = '1' then
            JUMP_addr <= s_REG_read_value_A;
          else
            JUMP_addr <= outbuffer_JUMP_addr;
          end if;

          if outbuffer_JUMP_true = '1' then
            JUMP_true <= '1';
          elsif s_jump_true_if_eq = '1' and s_REG_read_value_A = s_REG_read_value_B then
            JUMP_true <= '1';
          elsif s_jump_true_if_ne = '1' and s_REG_read_value_A /= s_REG_read_value_B then
            JUMP_true <= '1';
          else
            JUMP_true <= '0';
          end if;

          ALU_operator <= outbuffer_ALU_operator;
          MEM_read <= outbuffer_MEM_read;
          MEM_write <= outbuffer_MEM_write;
          REG_write <= outbuffer_REG_write;
          REG_write_addr <= outbuffer_REG_write_addr;

          s_REG_write <= '0'; -- write already done

          state <= s0;
      
      end case ;
    end if;
  end process;
        

 end architecture ; -- arch