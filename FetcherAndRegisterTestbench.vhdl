library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity FetcherAndRegisterTestbench is

end entity ; -- FetcherAndRegisterTestbench


architecture arch of FetcherAndRegisterTestbench is

component FetcherAndRegister port (

    debug: out std_logic_vector(7 downto 0) := (others => '0');

    PC: in std_logic_vector(31 downto 0);
    RAM_select: in std_logic;
    clock: in std_logic;
    reset: in std_logic;

    timer_int: out std_logic := '0';

    Interrupt_mask: out std_logic_vector(7 downto 0);
    Interrupt_int: in std_logic := '0';
    Interrupt_numbers: in std_logic_vector(7 downto 0);

    TLB_set_do: out std_logic := '0';
    TLB_set_index: out std_logic_vector(2 downto 0);
    TLB_set_entry: out std_logic_vector(63 downto 0);

    TLB_data_exception: in std_logic;
    TLB_data_exception_read_or_write: in std_logic;

    TLB_instruction_bad: in std_logic;

    hold: buffer std_logic:= '0';

    BACK_REG_write: in std_logic;
    BACK_REG_write_addr: in std_logic_vector(4 downto 0);
    BACK_REG_write_data: in std_logic_vector(31 downto 0);
    BACK_REG_write_byte_only: in std_logic;
    BACK_REG_write_byte_pos: in std_logic_vector(1 downto 0);

    BASERAM_data: in std_logic_vector(31 downto 0);
    EXTRAM_data: in std_logic_vector(31 downto 0);

    ALU_operator: out std_logic_vector(3 downto 0);
    ALU_numA: out std_logic_vector(31 downto 0);
    ALU_numB: out std_logic_vector(31 downto 0);

    JUMP_true: out std_logic;
    JUMP_addr: out std_logic_vector(31 downto 0);

    MEM_read: out std_logic;
    MEM_write: out std_logic;
    MEM_write_byte_only: out std_logic := '0';
    MEM_data: out std_logic_vector(31 downto 0);

    hold_from_memory: in std_logic;

    REG_write: out std_logic;
    REG_write_byte_only: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0)  -- we have 32 registers
  ) ;
 end component ; -- FetcherAndRegister 

  signal clock: std_logic := '0';

  signal ALU_operator:  std_logic_vector(3 downto 0);
  signal ALU_numA:  std_logic_vector(31 downto 0);
  signal ALU_numB:  std_logic_vector(31 downto 0);

  signal JUMP_true:  std_logic;
  signal JUMP_addr:  std_logic_vector(31 downto 0);

  signal MEM_read:  std_logic;
  signal MEM_write:  std_logic;
  signal MEM_data:  std_logic_vector(31 downto 0);

  signal REG_write:  std_logic;
  signal REG_write_byte_only: std_logic;
  signal REG_write_addr:  std_logic_vector(4 downto 0);  -- we have 32 registers

  signal BACK_REG_write : std_logic;
  signal BACK_REG_write_addr: std_logic_vector(4 downto 0);
  signal BACK_REG_write_data: std_logic_vector(31 downto 0);
  signal BACK_REG_write_byte_only : std_logic := '0';
  signal BACK_REG_write_byte_pos : std_logic_vector(1 downto 0);

  constant clk_period :time :=20 ns;
  signal data: std_logic_vector(31 downto 0);

begin

    instance: FetcherAndRegister port map (
        open,
        PC => x"80000000", 
        RAM_select => '0',
        clock => clock, 
        reset => '0',

        timer_int => open,
        Interrupt_mask => open,
        Interrupt_int => '0',
        Interrupt_numbers => (others => '0'),

        TLB_set_do => open, 
        TLB_set_index => open, 
        TLB_set_entry => open,
        TLB_data_exception => '0', 
        TLB_data_exception_read_or_write => '0', 
        TLB_instruction_bad => '0',

        hold=>open,

        BACK_REG_write => BACK_REG_write,
        BACK_REG_write_addr => BACK_REG_write_addr,
        BACK_REG_write_data => BACK_REG_write_data,
        BACK_REG_write_byte_only => BACK_REG_write_byte_only,
        BACK_REG_write_byte_pos => BACK_REG_write_byte_pos,

        BASERAM_data => data, -- instruction
        EXTRAM_data => x"00000000",

        ALU_operator => ALU_operator,
        ALU_numA => ALU_numA,
        ALU_numB => ALU_numB,

        JUMP_true => JUMP_true,
        JUMP_addr => JUMP_addr,

        MEM_read => MEM_read,
        MEM_write => MEM_write,
        MEM_write_byte_only => open,
        MEM_data => MEM_data,

        hold_from_memory => '0',

        REG_write => REG_write,
        REG_write_byte_only => REG_write_byte_only,
        REG_write_addr => REG_write_addr

        );

    process begin
        BACK_REG_write <= '1';
        BACK_REG_write_addr <= "11101"; -- sp
        BACK_REG_write_data <= x"DEADBEEF";
        data <= x"8c100000";
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        BACK_REG_write <= '1';
        BACK_REG_write_addr <= "11101"; -- sp
        BACK_REG_write_data <= x"DEADFACE";
        data <= "00000011111000000000100000100100"; -- and 31,0 -> 1
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        BACK_REG_write <= '0';
        data(31 downto 0) <= x"afbe0020";
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        wait;
    end process;

end architecture ; -- arch
