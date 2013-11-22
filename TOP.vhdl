library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP is
port (
    reset: in std_logic;
    CLK_From_Key: in std_logic;
    CLK11M0592: in std_logic;
    CLK50M: in std_logic;
    BaseRamAddr: out std_logic_vector(19 downto 0) := (others => '0');
    BaseRamData: inout std_logic_vector(31 downto 0) := (others => 'Z');
    BaseRamCE: out std_logic := '1';
    BaseRamOE: out std_logic := '1';
    BaseRamWE: out std_logic := '1';
    -- digit number
    DYP0: out std_logic_vector(6 downto 0) := (others => '0');
    DYP1: out std_logic_vector(6 downto 0) := (others => '0');

    ExtRamAddr: out std_logic_vector(19 downto 0) := (others => '0');
    ExtRamData: inout std_logic_vector(31 downto 0) := (others => 'Z');
    ExtRamCE: out std_logic := '1';
    ExtRamOE: out std_logic := '1';
    ExtRamWE: out std_logic := '1';

    -- FlashAddr: out std_logic_vector(22 downto 0);
    -- FlashData: inout std_logic_vector(15 downto 0) := (others => 'Z');
    -- FLASH_BYTE: in std_logic;
    -- FLASH_CE: in std_logic;
    -- FLASH_CE1: in std_logic;
    -- FLASH_CE2: in std_logic;
    -- FLASH_OE: in std_logic;
    -- FLASH_RP: in std_logic;
    -- FLASH_STS: in std_logic;
    -- FLASH_VPEN: in std_logic;
    -- FLASH_WE: in std_logic;

    FPGA_KEY: in std_logic_vector(3 downto 0);
    LED: out std_logic_vector(15 downto 0) := (others => '0');
    InterConn: inout std_logic_vector(9 downto 0) := (others => 'Z');
    SW_DIP: in std_logic_vector(31 downto 0);

    VGA_Blue: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Green: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Red: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Vhync: out std_logic := '0';
    VGA_Hhync: out std_logic := '0' );

end TOP;

architecture arch of TOP is


component FetcherAndRegister port (
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
    MEM_data: out std_logic_vector(31 downto 0);

    REG_write: out std_logic;
    REG_write_addr: out std_logic_vector(4 downto 0)  -- we have 32 registers
  ) ;
 end component ; -- FetcherAndRegister 

component ALUWrapper port (
    clock: in std_logic;
    reset: in std_logic;

    ALU_operator: in std_logic_vector(3 downto 0) ;
    ALU_numA: in std_logic_vector(31 downto 0) ;
    ALU_numB: in std_logic_vector(31 downto 0) ;

    ALU_output: out std_logic_vector(31 downto 0) := (others => '0');

    -- forward
    in_JUMP_true: in std_logic; 
    in_JUMP_use_alu: in std_logic; 
    in_JUMP_true_if_alu_out_true: in std_logic; 
    in_JUMP_addr: in std_logic_vector(31 downto 0); 
    in_MEM_read: in std_logic ;
    in_MEM_write: in std_logic ;
    in_MEM_data: in std_logic_vector(31 downto 0);
    in_REG_write: in std_logic ;
    in_REG_write_addr: in std_logic_vector(4 downto 0);

    JUMP_true: out std_logic := '0'; 
    JUMP_use_alu: out std_logic; 
    JUMP_true_if_alu_out_true: out std_logic := '0'; 
    JUMP_addr: out std_logic_vector(31 downto 0); 
    MEM_read: out std_logic := '0';
    MEM_write: out std_logic := '0';
    MEM_data: out std_logic_vector(31 downto 0);
    REG_write: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0)
  ) ;
end component; -- ALUWrapper

component Memory port (
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

    EXTRAM_CE : out  STD_LOGIC;
    EXTRAM_OE : out  STD_LOGIC;
    EXTRAM_WE : out  STD_LOGIC; -- base ram stores data
    EXTRAM_addr: out std_logic_vector(19 downto 0);
    EXTRAM_data: inout std_logic_vector(31 downto 0);
    DYP0: out std_logic_vector(6 downto 0) := (others => '0');
    DYP1: out std_logic_vector(6 downto 0) := (others => '0');
    LED: out std_logic_vector(15 downto 0) := (others => '0')
  ) ;
end component ; -- Memory

component PCdecider port (
    clock: in std_logic;
    reset: in std_logic;

    JUMP_true: in std_logic;
    JUMP_use_alu: in std_logic;
    JUMP_true_if_alu_out_true: in std_logic;
    JUMP_addr: in std_logic_vector(31 downto 0);

    ALU_output: in std_logic_vector(31 downto 0);

    PC: out std_logic_vector(31 downto 0)
  ) ;
end component; -- PCdecider

    -- reset is '1' if not clicked, that's not what we want
    signal real_reset: std_logic := '0';
    signal real_clk_from_key: std_logic := '0';

    signal PC: std_logic_vector(31 downto 0) := (others => '0');

    signal ALU_operator: std_logic_vector(3 downto 0) := "1111";
    signal ALU_numA: std_logic_vector(31 downto 0) := (others => '0');
    signal ALU_numB: std_logic_vector(31 downto 0) := (others => '0');
    signal ALU_output: std_logic_vector(31 downto 0) := (others => '0');

    signal A_JUMP_true: std_logic := '0'; 
    signal A_JUMP_use_alu: std_logic := '0'; 
    signal A_JUMP_true_if_alu_out_true: std_logic := '0'; 
    signal A_JUMP_addr: std_logic_vector(31 downto 0) := (others => '0'); 
    signal B_JUMP_true: std_logic := '0'; 
    signal B_JUMP_use_alu: std_logic := '0'; 
    signal B_JUMP_true_if_alu_out_true: std_logic := '0'; 
    signal B_JUMP_addr: std_logic_vector(31 downto 0) := (others => '0'); 

    signal A_MEM_read: std_logic := '0'; 
    signal A_MEM_write: std_logic := '0'; 
    signal A_MEM_data: std_logic_vector(31 downto 0) := (others => '0');
    signal B_MEM_read: std_logic := '0'; 
    signal B_MEM_write: std_logic := '0'; 
    signal B_MEM_data: std_logic_vector(31 downto 0) := (others => '0');

    signal MEM_output: std_logic_vector(31 downto 0) := (others => '0');

    signal A_REG_write: std_logic := '0';
    signal A_REG_write_addr: std_logic_vector(4 downto 0) := (others => '0');
    signal B_REG_write: std_logic := '0';
    signal B_REG_write_addr: std_logic_vector(4 downto 0) := (others => '0');
    signal C_REG_write: std_logic := '0';
    signal C_REG_write_addr: std_logic_vector(4 downto 0) := (others => '0');

    signal s_data: std_logic_vector(31 downto 0);
    
begin

    real_reset <= not reset;
    real_clk_from_key <= CLK11M0592;
    s_data <= SW_DIP;

FetcherAndRegister0: FetcherAndRegister port map (
    PC, real_clk_from_key, real_reset, 
    C_REG_write,
    C_REG_write_addr,
    MEM_output, -- reg write data
    BaseRamCE, BaseRamOE, BaseRamWE, 
    BaseRamAddr, 
    BaseRamData,  -- data from sw
    ALU_operator, ALU_numA, ALU_numB,
    A_JUMP_true, A_JUMP_use_alu, A_JUMP_true_if_alu_out_true, A_JUMP_addr,
    A_MEM_read, A_MEM_write, A_MEM_data,
    A_REG_write, A_REG_write_addr
    );

ALUWrapper0: ALUWrapper port map (
    real_clk_from_key, real_reset,
    ALU_operator, ALU_numA, ALU_numB, ALU_output,
    A_JUMP_true, A_JUMP_use_alu, 
    A_JUMP_true_if_alu_out_true, A_JUMP_addr,
    A_MEM_read, A_MEM_write, 
    A_MEM_data, 
    A_REG_write, A_REG_write_addr,
    B_JUMP_true, B_JUMP_use_alu, 
    B_JUMP_true_if_alu_out_true, B_JUMP_addr,
    B_MEM_read, B_MEM_write,
    B_MEM_data, 
    B_REG_write, B_REG_write_addr);

Mem0: Memory port map (
    real_clk_from_key, real_reset,
    ALU_output, B_MEM_read, B_MEM_write,
    B_MEM_data,
    MEM_output, 
    B_REG_write, B_REG_write_addr, 
    C_REG_write, C_REG_write_addr,
    ExtRamCE, ExtRamOE, ExtRamWE,
    ExtRamAddr, ExtRamData,
    DYP0, DYP1, LED);

PC0: PCdecider port map(
    real_clk_from_key, real_reset,
    B_JUMP_true, B_JUMP_use_alu,
    B_JUMP_true_if_alu_out_true, B_JUMP_addr,
    ALU_output, PC);

end arch;