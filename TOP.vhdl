library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP is
port (
    reset: in std_logic;
    CLK_From_Key: in std_logic;
    CLK11M0592: in std_logic;
    CLK50M: in std_logic;
    BaseRamAddr: inout std_logic_vector(19 downto 0) := (others => '0');
    BaseRamData: inout std_logic_vector(31 downto 0) := (others => 'Z');
    BaseRamCE: out std_logic := '1';
    BaseRamOE: out std_logic := '1';
    BaseRamWE: out std_logic := '1';
    -- digit number
    DYP0: out std_logic_vector(6 downto 0) := (others => '0');
    DYP1: out std_logic_vector(6 downto 0) := (others => '0');

    ExtRamAddr: inout std_logic_vector(19 downto 0) := (others => '0');
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

    hold: buffer std_logic:= '0';

    BACK_REG_write: in std_logic;
    BACK_REG_write_addr: in std_logic_vector(4 downto 0);
    BACK_REG_write_data: in std_logic_vector(31 downto 0);

    BASERAM_data: in std_logic_vector(31 downto 0);
    EXTRAM_data: in std_logic_vector(31 downto 0);

    ALU_operator: out std_logic_vector(3 downto 0);
    ALU_numA: out std_logic_vector(31 downto 0);
    ALU_numB: out std_logic_vector(31 downto 0);

    JUMP_true: out std_logic;
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
    in_MEM_read: in std_logic ;
    in_MEM_write: in std_logic ;
    in_MEM_data: in std_logic_vector(31 downto 0);
    in_REG_write: in std_logic ;
    in_REG_write_addr: in std_logic_vector(4 downto 0);

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
end component ; -- Memory

component PCdecider port (
    clock: in std_logic;
    reset: in std_logic;

    hold: in std_logic;

    JUMP_true: in std_logic;
    JUMP_addr: in std_logic_vector(31 downto 0);

    BASERAM_addr: inout std_logic_vector(19 downto 0);
    EXTRAM_addr: inout std_logic_vector(19 downto 0);

    PC: buffer std_logic_vector(31 downto 0)
  ) ;
end component; -- PCdecider

    -- reset is '1' if not clicked, that's not what we want
    signal real_reset: std_logic := '0';
    signal real_clock: std_logic := '0';
    signal clk25M: std_logic := '0';

    signal PC: std_logic_vector(31 downto 0) := (others => '0');
    signal A_HOLD: std_logic := '0';

    signal ALU_operator: std_logic_vector(3 downto 0) := "1111";
    signal ALU_numA: std_logic_vector(31 downto 0) := (others => '0');
    signal ALU_numB: std_logic_vector(31 downto 0) := (others => '0');
    signal ALU_output: std_logic_vector(31 downto 0) := (others => '0');

    signal JUMP_true: std_logic := '0'; 
    signal JUMP_addr: std_logic_vector(31 downto 0) := (others => '0'); 

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

    signal s_state : std_logic_vector(1 downto 0) := "00";
    
begin

    divider : process( CLK50M )
    begin
        if rising_edge(CLK50M) then
            clk25M <= not clk25M;
        end if;
    end process ; -- divider

    real_reset <= not reset;
    real_clock <= CLK11M0592;

    BaseRamOE <= '0';
    BaseRamCE <= '0';
    ExtRamCE <= '0';
    ExtRamOE <= '0';

FetcherAndRegister0: FetcherAndRegister port map (
    PC, real_clock, real_reset, A_HOLD,
    C_REG_write,
    C_REG_write_addr,
    MEM_output, -- reg write data
    BaseRamData,  -- data from sw
    ExtRamData,
    ALU_operator, ALU_numA, ALU_numB,
    JUMP_true, JUMP_addr,
    A_MEM_read, A_MEM_write, A_MEM_data,
    A_REG_write, A_REG_write_addr
    );

ALUWrapper0: ALUWrapper port map (
    real_clock, real_reset,
    ALU_operator, ALU_numA, ALU_numB, ALU_output,
    A_MEM_read, A_MEM_write, 
    A_MEM_data, 
    A_REG_write, A_REG_write_addr,
    B_MEM_read, B_MEM_write,
    B_MEM_data, 
    B_REG_write, B_REG_write_addr);

Mem0: Memory port map (
    real_clock, real_reset,
    ALU_output, B_MEM_read, B_MEM_write,
    B_MEM_data,
    MEM_output, 
    B_REG_write, B_REG_write_addr, 
    C_REG_write, C_REG_write_addr,
    BaseRamWE, BaseRamAddr, BaseRamData,
    ExtRamWE, ExtRamAddr, ExtRamData,
    DYP0, DYP1, LED);

PC0: PCdecider port map(
    real_clock, real_reset, A_HOLD,
    JUMP_true,
    JUMP_addr,
    BaseRamAddr, ExtRamAddr,
    PC);

end arch;