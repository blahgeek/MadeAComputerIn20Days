library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MemoryTest is
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

    FPGA_KEY: in std_logic_vector(3 downto 0);
    LED: out std_logic_vector(15 downto 0) := (others => '0');
    InterConn: inout std_logic_vector(9 downto 0) := (others => 'Z');
    SW_DIP: in std_logic_vector(31 downto 0);

    VGA_Blue: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Green: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Red: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Vhync: out std_logic := '0';
    VGA_Hhync: out std_logic := '0' );

end entity ; -- MemoryTest

architecture arch of MemoryTest is

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

    -- reset is '1' if not clicked, that's not what we want
    signal real_reset: std_logic := '0';
    signal real_clk_from_key: std_logic := '0';

    signal data: std_logic_vector(31 downto 0);
    signal addr: std_logic_vector(31 downto 0);
    signal data_out: std_logic_vector(31 downto 0);

    signal if_r: std_logic;
    signal if_w: std_logic;

begin

    real_reset <= not reset;
    real_clk_from_key <= not CLK_From_Key;

    data(31 downto 16) <= (others => '0');
    data(15 downto 0) <= SW_DIP(15 downto 0);
    addr(31 downto 15) <= (others => '0');
    addr(14 downto 0) <= SW_DIP(30 downto 16);
    if_r <= not SW_DIP(31);
    if_w <= SW_DIP(31);
    LED <= data_out(15 downto 0);

    mem0: Memory port map (
        real_clk_from_key, real_reset,
        data, if_r, if_w, addr, data_out,
        '0', "00000", open, open,
        ExtRamCE, ExtRamOE, ExtRamWE,
        ExtRamAddr, ExtRamData,
        DYP0, DYP1, LED);

end architecture ; -- arch