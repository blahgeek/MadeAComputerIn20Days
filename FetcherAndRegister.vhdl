library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity FetcherAndRegister is
  port (
    PC: in std_logic_vector(31 downto 0);
    clock: in std_logic;
    reset: in std_logic;

    BACK_REG_write: in std_logic;
    BACK_REG_write_addr: in std_logic_vector(4 downto 0);
    BACK_REG_write_data: in std_logic_vector(31 downto 0);

    BASERAM_CE : out  STD_LOGIC;
    BASERAM_OE : out  STD_LOGIC;
    BASERAM_WE : out  STD_LOGIC; -- base ram stores instructions
    BASERAM_addr: out std_logic_vector(19 downto 0);
    BASERAM_data: inout std_logic_vector(31 downto 0);

    ALU_operator: out std_logic_vector(3 downto 0);
    ALU_numA: out std_logic_vector(31 downto 0);
    ALU_numB: out std_logic_vector(31 downto 0);

    JUMP_true: out std_logic;
    JUMP_use_alu: out std_logic;
    JUMP_true_if_alu_out_true: out std_logic;
    JUMP_addr: out std_logic_vector(31 downto 0);

    MEM_read: out std_logic;
    MEM_write: out std_logic;
    MEM_addr_or_data: out std_logic_vector(31 downto 0);
    MEM_use_aluout_as_addr: out std_logic;
    -- if it's set to 0: MEM use outbuffer_MEM_addr_or_data as addr, use ALU output as data
    -- else: MEM use outbuffer_MEM_addr_or_data as data, use ALU output as addr

    REG_write: out std_logic;
    REG_write_addr: out std_logic_vector(4 downto 0)  -- we have 32 registers
  ) ;
 end entity ; -- FetcherAndRegister 


 architecture arch of FetcherAndRegister is

 -- component Register
 --   port (
 --    clk: in std_logic;
 --    RegReadNumberA: in std_logic_vector(4 downto 0);
 --    RegReadNumberB: in std_logic_vector(4 downto 0);
 --    RegWrite: in std_logic;
 --    RegWriteNumber: in std_logic_vector(4 downto 0);
 --    RegWriteValue: in std_logic_vector(31 downto 0);
 --    RegReadValueA: out std_logic_vector(31 downto 0);
 --    RegReadValueB: out std_logic_vector(31 downto 0));
 -- end component;

  signal state: std_logic := '0';

  signal s_REG_clock: std_logic := '0';
  signal s_REG_write: std_logic;
  signal s_REG_read_number_B: std_logic_vector(4 downto 0);
  signal s_REG_read_value_B: std_logic_vector(31 downto 0);
  signal s_REG_read_number_A, s_REG_write_number: std_logic_vector(4 downto 0);
  signal s_REG_read_value_A, s_REG_write_value: std_logic_vector(31 downto 0);


  signal outbuffer_ALU_operator: std_logic_vector(3 downto 0);
  signal outbuffer_ALU_numA: std_logic_vector(31 downto 0);
  signal outbuffer_ALU_numB: std_logic_vector(31 downto 0);

  signal outbuffer_JUMP_true: std_logic;
  signal outbuffer_JUMP_use_alu: std_logic;
  signal outbuffer_JUMP_true_if_alu_out_true: std_logic;
  signal outbuffer_JUMP_addr: std_logic_vector(31 downto 0);

  signal outbuffer_MEM_read: std_logic;
  signal outbuffer_MEM_write: std_logic;
  signal outbuffer_MEM_addr_or_data: std_logic_vector(31 downto 0);
  signal outbuffer_MEM_use_aluout_as_addr: std_logic;

  signal outbuffer_REG_write: std_logic;
  signal outbuffer_REG_write_addr: std_logic_vector(4 downto 0);

  signal immediate_sign_extend, immediate_zero_extend: std_logic_vector(31 downto 0);

  signal numA_from_reg, numB_from_reg: std_logic; -- if read register for ALU
  signal mem_addr_or_data_from_reg_B: std_logic;

begin

  -- REG0: Register port map(s_REG_clock, s_REG_read_number_A, s_REG_read_number_B,
  --                         s_REG_write, s_REG_write_number, 
  --                         s_REG_write_value, s_REG_read_value_A, s_REG_read_value_B);

  BASERAM_CE <= '0';
  BASERAM_OE <= '0';
  BASERAM_WE <= '1'; -- base ram always on READ
  BASERAM_addr <= PC(21 downto 2); -- 4 bit per addr
  BASERAM_data <= (others => 'Z');

  -- always compute immediate extend
  immediate_zero_extend(15 downto 0) <= BASERAM_data(15 downto 0);
  immediate_zero_extend(31 downto 16) <= (others => '0');
  immediate_sign_extend(15 downto 0) <= BASERAM_data(15 downto 0);
  immediate_sign_extend(31 downto 16) <= (others => BASERAM_data(15));

  s_REG_clock <= reset or (not clock); -- reverse

  process(clock, reset)
  begin
    if reset = '1' then
      state <= '0';

    elsif rising_edge(clock) then

      case( state ) is
      
        when '0' => -- state: read instruction
          
          if BASERAM_data(31 downto 26) = "000000" then -- R type
            outbuffer_JUMP_true_if_alu_out_true <= '0';

            if BASERAM_data(5) = '1' then -- 3 reg type
              numA_from_reg <= '1';
              s_REG_read_number_A <= BASERAM_data(25 downto 21); -- rs
              numB_from_reg <= '1';
              s_REG_read_number_B <= BASERAM_data(20 downto 16); -- rt
              outbuffer_JUMP_true <= '0';
              outbuffer_MEM_read <= '0';
              outbuffer_MEM_use_aluout_as_addr <= '0'; -- so MEM would forward ALU output as data
              outbuffer_MEM_write <= '0';
              outbuffer_REG_write <= '1';
              outbuffer_REG_write_addr <= BASERAM_data(15 downto 11); -- rd
              outbuffer_ALU_operator <= BASERAM_data(3 downto 0);
            else
              if BASERAM_data(2) = '1' then -- also 3 reg type
                -- yes, rs and rt is swapped
                numB_from_reg <= '1';
                s_REG_read_number_B <= BASERAM_data(25 downto 21); -- rs
                numA_from_reg <= '1';
                s_REG_read_number_A <= BASERAM_data(20 downto 16); -- rt
                outbuffer_JUMP_true <= '0';
                outbuffer_MEM_read <= '0';
                outbuffer_MEM_use_aluout_as_addr <= '0'; -- so MEM would forward ALU output as data
                outbuffer_MEM_write <= '0';
                outbuffer_REG_write <= '1';
                outbuffer_REG_write_addr <= BASERAM_data(15 downto 11); -- rd
                case( BASERAM_data(1 downto 0) ) is
                  when "00" => outbuffer_ALU_operator <= "1100"; -- C, "<<"
                  when "10" => outbuffer_ALU_operator <= "1101"; -- D, >>, logical
                  when "11" => outbuffer_ALU_operator <= "1110"; -- E, >>, arithmetic
                  when others => outbuffer_ALU_operator <= "1111"; -- do nothing
                end case ;
              else
                if BASERAM_data(3) = '1' then  -- not jr
                  numA_from_reg <= '1';
                  s_REG_read_number_A <= BASERAM_data(20 downto 16); -- rt
                  numB_from_reg <= '0'; -- B is immediate
                  outbuffer_ALU_numB(4 downto 0) <= BASERAM_data(10 downto 6);
                  outbuffer_ALU_numB(31 downto 5) <= (others => '0');
                  outbuffer_JUMP_true <= '0';
                  outbuffer_MEM_read <= '0';
                  outbuffer_MEM_use_aluout_as_addr <= '0'; -- so MEM would forward ALU output as data
                  outbuffer_MEM_write <= '0';
                  outbuffer_REG_write <= '1';
                  outbuffer_REG_write_addr <= BASERAM_data(15 downto 11); -- rd
                  case( BASERAM_data(1 downto 0) ) is
                    when "00" => outbuffer_ALU_operator <= "1100"; -- C, "<<"
                    when "10" => outbuffer_ALU_operator <= "1101"; -- D, >>, logical
                    when "11" => outbuffer_ALU_operator <= "1110"; -- E, >>, arithmetic
                    when others => outbuffer_ALU_operator <= "1111"; -- do nothing
                  end case ;
                else -- jr
                  numA_from_reg <= '1';
                  s_REG_read_number_A <= BASERAM_data(25 downto 21); -- rs
                  numB_from_reg <= '0';
                  outbuffer_JUMP_true <= '1'; -- jump
                  outbuffer_JUMP_use_alu <= '1';
                  outbuffer_MEM_read <= '0';
                  outbuffer_MEM_use_aluout_as_addr <= '0'; -- so MEM would forward ALU output as data
                  outbuffer_MEM_write <= '0';
                  outbuffer_REG_write <= '0';
                  outbuffer_ALU_operator <= "1111"; -- do nothing, forward A
                end if;
              end if;
            end if;

          elsif BASERAM_data(31 downto 28) = "0000" then -- J type
            outbuffer_JUMP_true_if_alu_out_true <= '0';
            numA_from_reg <= '0';
            outbuffer_ALU_numA <= PC;
            numB_from_reg <= '0';
            outbuffer_ALU_numB(3 downto 0) <= "1000"; -- 8
            outbuffer_ALU_numB(31 downto 4) <= (others=>'0');
            outbuffer_ALU_operator <= "0001"; -- output PC+8
            outbuffer_JUMP_true <= '1'; -- jump
            outbuffer_JUMP_use_alu <= '0'; -- use address computed by me
            outbuffer_JUMP_addr(31 downto 28) <= PC(31 downto 28); -- this is wrong but it should be OK in our machine
            outbuffer_JUMP_addr(27 downto 2) <= BASERAM_data(25 downto 0);
            outbuffer_JUMP_addr(1 downto 0) <= "00";
            outbuffer_MEM_write <= '0';
            outbuffer_MEM_read <= '0';
            outbuffer_MEM_use_aluout_as_addr <= '0'; -- so MEM would forward ALU output as data
            if BASERAM_data(27 downto 26) = "10" then -- j
              outbuffer_REG_write <= '0';
            else -- jal
              outbuffer_REG_write <= '1';
              outbuffer_REG_write_addr <= "11111"; -- write to R31
            end if;

          else -- I type
            if BASERAM_data(31 downto 30) = "10" then -- lw or sw
              numA_from_reg <= '1';
              s_REG_read_number_A <= BASERAM_data(25 downto 21);
              numB_from_reg <= '0';
              outbuffer_ALU_numB <= immediate_sign_extend;
              outbuffer_ALU_operator <= "0001"; -- add
              outbuffer_JUMP_true <= '0';
              outbuffer_JUMP_true_if_alu_out_true <= '0';
              if BASERAM_data(29 downto 26) = "0011" then  -- lw
                outbuffer_MEM_read <= '1'; -- read memory!
                outbuffer_MEM_write <= '0';
                outbuffer_MEM_use_aluout_as_addr <= '1'; -- use ALU output as addr
                outbuffer_REG_write <= '1';
                outbuffer_REG_write_addr <= BASERAM_data(20 downto 16);
              else  -- sw
                outbuffer_MEM_read <= '0';
                outbuffer_MEM_write <= '1'; -- write memory!
                outbuffer_MEM_use_aluout_as_addr <= '1'; -- use ALU output as addr
                mem_addr_or_data_from_reg_B <= '1'; -- read reg B to mem_addr_or_data_from_reg_B
                s_REG_read_number_B <= BASERAM_data(20 downto 16);
                outbuffer_REG_write <= '0'; -- not write register
              end if;
            elsif BASERAM_data(31 downto 26) = "001111" then -- lui
              numA_from_reg <= '0';
              outbuffer_ALU_numA(31 downto 16) <= BASERAM_data(15 downto 0);
              outbuffer_ALU_numA(15 downto 0) <= (others => '0');
              numB_from_reg <= '0';
              outbuffer_ALU_operator <= "1111"; -- forward A
              outbuffer_JUMP_true <= '0';
              outbuffer_JUMP_true_if_alu_out_true <= '0';
              outbuffer_MEM_write <= '0';
              outbuffer_MEM_read <= '0';
              outbuffer_REG_write <= '1';
              outbuffer_REG_write_addr <= BASERAM_data(20 downto 16);
            elsif BASERAM_data(31 downto 29) = "000" then -- branch
              numA_from_reg <= '1';
              s_REG_read_number_A <= BASERAM_data(25 downto 21);
              numB_from_reg <= '1';
              s_REG_read_number_B <= BASERAM_data(20 downto 16);
              outbuffer_JUMP_true <= '0';
              outbuffer_JUMP_true_if_alu_out_true <= '1';
              outbuffer_JUMP_use_alu <= '0';
              outbuffer_JUMP_addr(31 downto 2) <= std_logic_vector(unsigned(PC)+1+unsigned(BASERAM_data(15 downto 0)));
              outbuffer_JUMP_addr(1 downto 0) <= "00";
              outbuffer_MEM_read <= '0';
              outbuffer_MEM_write <= '0';
              outbuffer_REG_write <= '0';
              if BASERAM_data(28 downto 26) = "100" then -- beq
                outbuffer_ALU_operator <= "1000";
              else -- bne
                outbuffer_ALU_operator <= "1001";
              end if;
            else -- other I type
              numA_from_reg <= '1';
              s_REG_read_number_A <= BASERAM_data(25 downto 21);
              numB_from_reg <= '0';
              outbuffer_JUMP_true <= '0';
              outbuffer_JUMP_true_if_alu_out_true <= '0';
              outbuffer_MEM_write <= '0';
              outbuffer_MEM_read <= '0';
              outbuffer_REG_write <= '1';
              outbuffer_REG_write_addr <= BASERAM_data(20 downto 16);
              case( BASERAM_data(29 downto 26) ) is
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

          state <= '1';
      
        when others =>  -- state: now we got data from register

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

          if mem_addr_or_data_from_reg_B = '1' then
            MEM_addr_or_data <= s_REG_read_value_B;
          else
            MEM_addr_or_data <= outbuffer_MEM_addr_or_data;
          end if;


          ALU_operator <= outbuffer_ALU_operator;
          JUMP_true <= outbuffer_JUMP_true;
          JUMP_use_alu <= outbuffer_JUMP_use_alu;
          JUMP_true_if_alu_out_true <= outbuffer_JUMP_true_if_alu_out_true;
          JUMP_addr <= outbuffer_JUMP_addr;
          MEM_read <= outbuffer_MEM_read;
          MEM_write <= outbuffer_MEM_write;
          MEM_addr_or_data <= outbuffer_MEM_addr_or_data;
          MEM_use_aluout_as_addr <= outbuffer_MEM_use_aluout_as_addr;
          REG_write <= outbuffer_REG_write;
          REG_write_addr <= outbuffer_REG_write_addr;

          s_REG_write <= '0'; -- write already done

          state <= '0';
      
      end case ;
    end if;
  end process;
        

 end architecture ; -- arch