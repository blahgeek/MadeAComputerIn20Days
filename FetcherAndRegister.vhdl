library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity FetcherAndRegister is
  port (

    debug: out std_logic_vector(7 downto 0) := (others => '0');

    PC: in std_logic_vector(31 downto 0);
    RAM_select: in std_logic;
    clock: in std_logic;
    reset: in std_logic;

    TLB_set_do: out std_logic := '0';
    TLB_set_index: out std_logic_vector(2 downto 0);
    TLB_set_entry: out std_logic_vector(63 downto 0);

    TLB_data_exception: in std_logic;
    TLB_data_exception_read_or_write: in std_logic;

    TLB_instruction_bad: in std_logic;

    hold: buffer std_logic := '0';

    -- signals from 5th stage, for writing registers
    BACK_REG_write: in std_logic;
    BACK_REG_write_addr: in std_logic_vector(4 downto 0);
    BACK_REG_write_data: in std_logic_vector(31 downto 0);
    BACK_REG_write_byte_only: in std_logic;
    BACK_REG_write_byte_pos: in std_logic_vector(1 downto 0);

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
    MEM_write_byte_only: out std_logic := '0';
    MEM_data: out std_logic_vector(31 downto 0);
    -- use ALUout as addr
    hold_from_memory: in std_logic;

    REG_write: out std_logic := '0';
    REG_write_byte_only: out std_logic := '0';
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
    RegWriteByteOnly: in STD_LOGIC;
    RegWriteBytePos: in std_logic_vector(1 downto 0);
    RegReadValueA: out std_logic_vector(31 downto 0);
    RegReadValueB: out std_logic_vector(31 downto 0));
 end component;

  type state_type is (s0, s1, s2, s3);
  signal state: state_type := s0;

  type jump_condition_type is (none, eq, gez, gz, lez, lz, ne);
  signal s_jump_true_if_condition: jump_condition_type := none;

  type regs is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
  signal REGS_C0: regs:= (others => (others => '0'));

  signal s_numA_to_c0: std_logic := '0';
  signal s_numA_to_c0_addr: std_logic_vector(4 downto 0);

  signal s_REG_clock: std_logic := '0';
  signal s_REG_write: std_logic;
  signal s_REG_write_byte_only: std_logic := '0';
  signal s_REG_write_byte_pos: std_logic_vector(1 downto 0) := "00";
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
  signal outbuffer_MEM_write_byte_only: std_logic := '0';
  signal outbuffer_MEM_data: std_logic_vector(31 downto 0);

  signal outbuffer_REG_write: std_logic := '0';
  signal outbuffer_REG_write_addr: std_logic_vector(4 downto 0);
  signal outbuffer_REG_write_byte_only: std_logic := '0';

  signal immediate_sign_extend, immediate_zero_extend: std_logic_vector(31 downto 0);

  signal numA_from_reg, numB_from_reg: std_logic; -- if read register for ALU
  signal mem_data_from_reg_B: std_logic;

  signal s_jump_addr_from_reg_a: std_logic := '0';
  signal s_link_if_jump_true: std_logic := '0';

  signal s_data : std_logic_vector(31 downto 0):= (others => '0');

  signal s_last_last_write_reg: std_logic_vector(4 downto 0);
  signal s_last_write_reg: std_logic_vector(4 downto 0);

  -- skip one instruction, used after syscall, exception etc
  signal s_skip_next, s_skip_this: std_logic:= '0';
  signal s_exception: std_logic := '0';
  signal s_exception_cause: std_logic_vector(4 downto 0):= (others => '0');

  signal s_TLB_set_do: std_logic := '0';

begin

  with RAM_select select
    s_data <= BASERAM_data when '0',
              EXTRAM_data when others;

  REG0: Registers port map(s_REG_clock, reset, s_REG_read_number_A, s_REG_read_number_B,
                          s_REG_write, s_REG_write_number, 
                          s_REG_write_value, s_REG_write_byte_only,
                          s_REG_write_byte_pos,
                          s_REG_read_value_A, s_REG_read_value_B);

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
      REG_write_byte_only <= '0';
      s_numA_to_c0 <= '0';
      REGS_C0 <= (others => (others => '0'));
      hold <= '0';
      s_last_last_write_reg <= (others => '0');
      s_last_write_reg <= (others => '0');
      s_skip_this <= '0';
      s_skip_next <= '0';
      s_exception <= '0';
      s_TLB_set_do <= '0';
      TLB_set_do <= '0';
      debug <= (others => '0');

    elsif rising_edge(clock) then

      debug(3) <= TLB_data_exception;

      case( state ) is
      
        when s0 => -- state: read instruction

          debug(7 downto 4) <= PC(5 downto 2);

          if TLB_data_exception = '1' then 

            s_exception <= '1';
            if TLB_data_exception_read_or_write = '0' then --read
              debug(1 downto 0) <= "10";
              s_exception_cause <= "00010";  -- FIXME
            else
              debug(1 downto 0) <= "11";
              s_exception_cause <= "00011"; -- FIXME
            end if;

          elsif TLB_instruction_bad = '1' then

            s_exception <= '1';
            debug(1 downto 0) <= "01";
            s_exception_cause <= "00001";  -- FIXME

          else

            if s_data(31 downto 26) = "010000" then -- super command!
              -- TODO: check C0(12) here
              s_jump_true_if_condition <= none;
              outbuffer_MEM_read <= '0';
              outbuffer_MEM_write <= '0';
              if s_data(5 downto 0) = "011000" then -- eret
                s_numA_to_c0 <= '0';
                numA_from_reg <= '0';
                numB_from_reg <= '0';
                outbuffer_ALU_operator <= "1111";
                outbuffer_REG_write <= '0';
                REGS_C0(12)(1) <= '0';
                outbuffer_JUMP_true <= '1';
                outbuffer_JUMP_addr <= REGS_C0(14); -- EPC
              elsif s_data(5 downto 0) = "000000" then --mfc0/mtc0
                numB_from_reg <= '0';
                outbuffer_ALU_operator <= "1111";
                outbuffer_JUMP_true <= '0';
                if s_data(25 downto 21) = "00000" then --mfc0
                  numA_from_reg <= '0';
                  outbuffer_ALU_numA <= REGS_C0(to_integer(unsigned(s_data(15 downto 11))));
                  outbuffer_REG_write <= '1';
                  outbuffer_REG_write_byte_only <= '0';
                  outbuffer_REG_write_addr <= s_data(20 downto 16);
                else  -- mtc0
                  s_numA_to_c0 <= '1';
                  s_numA_to_c0_addr <= s_data(15 downto 11);
                  s_REG_read_number_A <= s_data(20 downto 16);
                  outbuffer_REG_write <= '0';
                end if;
              else  -- tlbwi 
                numA_from_reg <= '0';
                numB_from_reg <= '0';
                outbuffer_ALU_operator <= "1111";
                outbuffer_REG_write <= '0';
                outbuffer_JUMP_true <= '0';
                TLB_set_index <= REGS_C0(0)(2 downto 0);
                TLB_set_entry(63) <= '0';
                TLB_set_entry(62 downto 44) <= REGS_C0(10)(31 downto 13);
                TLB_set_entry(43 downto 24) <= REGS_C0(2)(25 downto 6);
                TLB_set_entry(23 downto 22) <= REGS_C0(2)(1 downto 0);
                TLB_set_entry(21 downto 2) <= REGS_C0(3)(25 downto 6);
                TLB_set_entry(1 downto 0) <= REGS_C0(3)(1 downto 0);
                s_TLB_set_do <= '1';
              end if;

            elsif s_data(31 downto 26) = "000000" then -- R type
              s_jump_true_if_condition <= none;
              s_numA_to_c0 <= '0';

              if s_data(5 downto 0) = "001100" then  -- SYSCALL!
                numA_from_reg <= '0';
                numB_from_reg <= '0';
                s_exception_cause <= "01000"; -- syscall only
                s_exception <= '1';

              elsif s_data(5) = '1' then -- 3 reg type
                numA_from_reg <= '1';
                s_REG_read_number_A <= s_data(25 downto 21); -- rs
                numB_from_reg <= '1';
                s_REG_read_number_B <= s_data(20 downto 16); -- rt
                outbuffer_JUMP_true <= '0';
                outbuffer_MEM_read <= '0';
                outbuffer_MEM_write <= '0';
                outbuffer_REG_write <= '1';
                outbuffer_REG_write_byte_only <= '0';
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
                  outbuffer_REG_write_byte_only <= '0';
                  outbuffer_REG_write_addr <= s_data(15 downto 11); -- rd
                  case( s_data(1 downto 0) ) is
                    when "00" => outbuffer_ALU_operator <= "1100"; -- C, "<<"
                    when "10" => outbuffer_ALU_operator <= "1101"; -- D, >>, logical
                    when "11" => outbuffer_ALU_operator <= "1110"; -- E, >>, arithmetic
                    when others => outbuffer_ALU_operator <= "1111"; -- do nothing
                  end case ;
                else
                  if s_data(3) = '0' then  -- not jr/jalr
                    numA_from_reg <= '1';
                    s_REG_read_number_A <= s_data(20 downto 16); -- rt
                    numB_from_reg <= '0'; -- B is immediate
                    outbuffer_ALU_numB(4 downto 0) <= s_data(10 downto 6);
                    outbuffer_ALU_numB(31 downto 5) <= (others => '0');
                    outbuffer_JUMP_true <= '0';
                    outbuffer_MEM_read <= '0';
                    outbuffer_MEM_write <= '0';
                    outbuffer_REG_write <= '1';
                    outbuffer_REG_write_byte_only <= '0';
                    outbuffer_REG_write_addr <= s_data(15 downto 11); -- rd
                    case( s_data(1 downto 0) ) is
                      when "00" => outbuffer_ALU_operator <= "1100"; -- C, "<<"
                      when "10" => outbuffer_ALU_operator <= "1101"; -- D, >>, logical
                      when "11" => outbuffer_ALU_operator <= "1110"; -- E, >>, arithmetic
                      when others => outbuffer_ALU_operator <= "1111"; -- do nothing, including nop
                    end case ;
                  else -- jr or jalr
                    if s_data(0) = '1' then -- jalr
                      outbuffer_REG_write_addr <= "11111"; -- write to $31
                      outbuffer_REG_write <= '1';
                      outbuffer_REG_write_byte_only <= '0';
                    else
                      outbuffer_REG_write <= '0';
                    end if;
                    numA_from_reg <= '0';
                    outbuffer_ALU_numA <= PC;
                    numB_from_reg <= '0';
                    outbuffer_ALU_numB(3 downto 0) <= "1000";
                    outbuffer_ALU_numB(31 downto 4) <= (others => '0');
                    outbuffer_ALU_operator <= "0001";  -- output PC+8
                    outbuffer_JUMP_true <= '1'; -- jump
                    s_REG_read_number_A <= s_data(25 downto 21); -- rs
                    s_jump_addr_from_reg_a <= '1';
                    outbuffer_MEM_read <= '0';
                    outbuffer_MEM_write <= '0';
                  end if;
                end if;
              end if;

            elsif s_data(31 downto 26) = "000010" or s_data(31 downto 26) = "000011" then -- J type
              s_numA_to_c0 <= '0';
              s_jump_true_if_condition <= none;
              s_jump_addr_from_reg_a <= '0';
              numA_from_reg <= '0';
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
                outbuffer_REG_write_byte_only <= '0';
                outbuffer_REG_write_addr <= "11111"; -- write to R31
              end if;

            else -- I type
              s_numA_to_c0 <= '0';
              if s_data(31 downto 30) = "10" then -- lw or sw
                numA_from_reg <= '1';
                s_REG_read_number_A <= s_data(25 downto 21);
                numB_from_reg <= '0';
                outbuffer_ALU_numB <= immediate_sign_extend;
                outbuffer_ALU_operator <= "0001"; -- add
                outbuffer_JUMP_true <= '0';
                s_jump_true_if_condition <= none;
                if s_data(29 downto 26) = "0011" or 
                   s_data(29 downto 26) = "0000" or 
                   s_data(29 downto 26) = "0100" then  -- lw or lb or lbu
                   -- FIXME! lbu
                  outbuffer_MEM_read <= '1'; -- read memory!
                  outbuffer_MEM_write <= '0';
                  outbuffer_REG_write <= '1';
                  outbuffer_REG_write_addr <= s_data(20 downto 16);
                  outbuffer_REG_write_byte_only <= not s_data(26); -- if lb
                else  -- sw or sb
                  if s_data(29 downto 26) = "1000" then -- sb
                    outbuffer_MEM_write_byte_only <= '1';
                  else
                    outbuffer_MEM_write_byte_only <= '0';
                  end if;
                  outbuffer_MEM_read <= '0';
                  outbuffer_MEM_write <= '1'; -- write memory!
                  mem_data_from_reg_B <= '1'; -- read reg B to mem_data_from_reg_B
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
                s_jump_true_if_condition <= none;
                outbuffer_MEM_write <= '0';
                outbuffer_MEM_read <= '0';
                outbuffer_REG_write <= '1';
                outbuffer_REG_write_byte_only <= '0';
                outbuffer_REG_write_addr <= s_data(20 downto 16);
              elsif s_data(31 downto 29) = "000" then -- branch

                numA_from_reg <= '0';
                outbuffer_ALU_numA <= PC;
                numB_from_reg <= '0';
                outbuffer_ALU_numB(3 downto 0) <= "1000";
                outbuffer_ALU_numB(31 downto 4) <= (others => '0');
                outbuffer_ALU_operator <= "0001";  -- output PC+8

                s_REG_read_number_A <= s_data(25 downto 21); -- read it from reg but not put this to ALU
                s_REG_read_number_B <= s_data(20 downto 16);

                outbuffer_JUMP_true <= '0';
                s_jump_addr_from_reg_a <= '0';
                outbuffer_JUMP_addr(27 downto 2) <= std_logic_vector(
                        signed(PC(27 downto 2))+
                        signed(s_data(15 downto 0))+1);
                outbuffer_JUMP_addr(31 downto 28) <= PC(31 downto 28);
                outbuffer_JUMP_addr(1 downto 0) <= "00";
                outbuffer_MEM_read <= '0';
                outbuffer_MEM_write <= '0';

                outbuffer_REG_write <= '0'; -- well, we dont know it YET
                outbuffer_REG_write_byte_only <= '0';
                outbuffer_REG_write_addr <= "11111"; -- write to R31

                if s_data(28 downto 26) = "100" then -- beq
                  s_jump_true_if_condition <= eq;
                  s_link_if_jump_true <= '0'; -- will not link
                elsif s_data(28 downto 26) = "111" then
                  s_jump_true_if_condition <= gz;
                  s_link_if_jump_true <= '0'; -- will not link
                elsif s_data(28 downto 26) = "110" then
                  s_jump_true_if_condition <= lez;
                  s_link_if_jump_true <= '0'; -- will not link
                elsif s_data(28 downto 26) = "001" and s_data(16) = '1' then -- bgez
                  s_jump_true_if_condition <= gez;
                  s_link_if_jump_true <= s_data(20); -- link?
                elsif s_data(28 downto 26) = "001" and s_data(16) = '0' then
                  s_jump_true_if_condition <= lz; 
                  s_link_if_jump_true <= s_data(20); -- link?
                else -- bne
                  s_jump_true_if_condition <= ne;
                  s_link_if_jump_true <= '0'; -- will not link
                end if;
              else -- other I type
                numA_from_reg <= '1';
                s_REG_read_number_A <= s_data(25 downto 21);
                numB_from_reg <= '0';
                outbuffer_JUMP_true <= '0';
                s_jump_true_if_condition <= none;
                outbuffer_MEM_write <= '0';
                outbuffer_MEM_read <= '0';
                outbuffer_REG_write <= '1';
                outbuffer_REG_write_byte_only <= '0';
                outbuffer_REG_write_addr <= s_data(20 downto 16);
                case( s_data(29 downto 26) ) is
                  when "1000" => -- addi
                    outbuffer_ALU_numB <= immediate_sign_extend;
                    outbuffer_ALU_operator <= "0000";
                  when "1001" => -- addiu
                    outbuffer_ALU_numB <= immediate_sign_extend;
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

          end if;

          s_REG_write <= BACK_REG_write;
          s_REG_write_number <= BACK_REG_write_addr;
          s_REG_write_value <= BACK_REG_write_data;
          s_REG_write_byte_only <= BACK_REG_write_byte_only;
          s_REG_write_byte_pos <= BACK_REG_write_byte_pos;

          state <= s1;

        when s1 =>
          if s_last_last_write_reg /= "00000" and
            (s_last_last_write_reg = s_REG_read_number_A 
              or s_last_last_write_reg = s_REG_read_number_B) then
            hold <= '1';
          elsif s_last_write_reg /= "00000" and
            (s_last_write_reg = s_REG_read_number_A
              or s_last_write_reg = s_REG_read_number_B) then
            hold <= '1';
          else
            hold <= '0';
          end if;
          s_REG_write <= '0'; -- write already done

          if s_TLB_set_do = '1' then
            s_TLB_set_do <= '0';
            TLB_set_do <= '1';
          end if;

          state <= s2;

        when s2 => 
          if hold_from_memory = '0' then
            s_last_last_write_reg <= s_last_write_reg;
          end if;

          if hold_from_memory = '1' and s_exception = '0' then
            hold <= '1';
          end if;

          if s_exception = '1' and s_skip_this = '0' then

            s_exception <= '0';

            if s_exception_cause = "00010" or s_exception_cause = "00011" then -- FIXME its TLB data exception
              REGS_C0(14) <= std_logic_vector(unsigned(PC)-8); -- eret
            else
              REGS_C0(14) <= PC;  -- don't +4
            end if;
            REGS_C0(13)(6 downto 2) <= s_exception_cause;
            REGS_C0(12)(1) <= '1';
            numA_from_reg <= '0';
            numB_from_reg <= '0';
            s_jump_true_if_condition <= none;
            s_jump_addr_from_reg_a <= '0'; -- shit
            outbuffer_ALU_operator <= "1111";
            outbuffer_MEM_read <= '0';
            outbuffer_MEM_write <= '0';
            outbuffer_REG_write <= '0';
            outbuffer_JUMP_true <= '1'; --jump!
            outbuffer_JUMP_addr <= REGS_C0(15);  -- not standard

            s_skip_next <= '1'; -- there's no delay slot for exception

          end if;

          state <= s3;
      
        when s3 =>  -- state: now we got data from register

          if hold_from_memory = '0' then
            if not (s_jump_true_if_condition /= none and s_link_if_jump_true = '1') then
              if hold = '0' and outbuffer_REG_write = '1' then
                s_last_write_reg <= outbuffer_REG_write_addr;
              else
                s_last_write_reg <= "00000";
              end if;
            end if;
          end if;

          if hold = '1' or s_skip_this = '1' then
            ALU_operator <= "1111";
            ALU_numA <= (others => '0');
            ALU_numB <= (others => '0');
            JUMP_true <= '0';
            MEM_read <= '0';
            MEM_write <= '0';
            REG_write <= '0';
            s_skip_next <= '0';
            if hold = '1' and s_skip_this = '1' then -- F**K
              s_skip_this <= '1';
            else
              s_skip_this <= '0';
            end if;
          else
            if s_skip_next = '1' then
              s_skip_next <= '0';
              s_skip_this <= '1';
            end if;
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
              mem_data_from_reg_B <= '0';
            else
              MEM_data <= outbuffer_MEM_data;
            end if;

            if s_numA_to_c0 = '1' then
              REGS_C0(to_integer(unsigned(s_numA_to_c0_addr))) <= s_REG_read_value_A;
              s_numA_to_c0 <= '0';
            end if;

            if s_jump_addr_from_reg_a = '1' then
              JUMP_addr <= s_REG_read_value_A;
              s_jump_addr_from_reg_a <= '0';
            else
              JUMP_addr <= outbuffer_JUMP_addr;
            end if;

            if outbuffer_JUMP_true = '1' then
              JUMP_true <= '1';
            elsif (s_jump_true_if_condition = eq and s_REG_read_value_A = s_REG_read_value_B) or 
                  (s_jump_true_if_condition = ne and s_REG_read_value_A /= s_REG_read_value_B) or
                  (s_jump_true_if_condition = gez and signed(s_REG_read_value_A) >= 0) or
                  (s_jump_true_if_condition = gz and signed(s_REG_read_value_A) > 0) or
                  (s_jump_true_if_condition = lez and signed(s_REG_read_value_A) <= 0) or
                  (s_jump_true_if_condition = lz and signed(s_REG_read_value_A) < 0) then
              JUMP_true <= '1';
              if s_link_if_jump_true = '1' then
                REG_write <= '1';
                if hold_from_memory = '0' then
                  s_last_write_reg <= outbuffer_REG_write_addr;
                end if;
              end if;
            else
              JUMP_true <= '0';
              if s_jump_true_if_condition /= none and s_link_if_jump_true = '1' then
                REG_write <= '0';
                if hold_from_memory = '0' then
                  s_last_write_reg <= (others => '0');
                end if;
              end if;
            end if;

            ALU_operator <= outbuffer_ALU_operator;
            MEM_read <= outbuffer_MEM_read;
            MEM_write <= outbuffer_MEM_write;
            MEM_write_byte_only <= outbuffer_MEM_write_byte_only;

            if not (s_jump_true_if_condition /= none and s_link_if_jump_true = '1') then
              REG_write <= outbuffer_REG_write;
            end if;
            REG_write_addr <= outbuffer_REG_write_addr;
            REG_write_byte_only <= outbuffer_REG_write_byte_only;

            s_REG_read_number_A <= (others => '0');
            s_REG_read_number_B <= (others => '0');

          end if;

          TLB_set_do <= '0';

          state <= s0;
      
      end case ;
    end if;
  end process;
        

 end architecture ; -- arch
