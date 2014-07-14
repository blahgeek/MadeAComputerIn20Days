library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity VGATest is
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
    VGA_Vhync: buffer std_logic := '0';
    VGA_Hhync: buffer std_logic := '0' );
end entity ; -- VGATest

architecture arch of VGATest is
signal real_reset: std_logic:= '0';

component clk_wiz is port (
    clk_in: in std_logic;
    clk_out: out std_logic);
end component;

signal clk_out: std_logic;

component VGA_Controller is
    port (
        VGA_CLK : out std_logic;
        hs,vs   : buffer std_logic;
        oRed    : out std_logic_vector (2 downto 0);
        oGreen  : out std_logic_vector (2 downto 0);
        oBlue   : out std_logic_vector (2 downto 0);

        in_x:   in std_logic_vector(6 downto 0);
        in_y:   in std_logic_vector(4 downto 0);
        in_data:in std_logic_vector(6 downto 0);
        in_set: in std_logic;

        reset   : in  std_logic;
        CLK_in  : in  std_logic -- 50M
    );      
end component;

begin

    real_reset <= not reset;

    wiz0: clk_wiz port map(CLK11M0592, clk_out);

    vga0: VGA_Controller port map (
        open, VGA_Hhync, VGA_Vhync, VGA_Red, VGA_Green, VGA_Blue,
        SW_DIP(31 downto 25), SW_DIP(23 downto 19), SW_DIP(15 downto 9),
        SW_DIP(7), real_reset, clk_out);

    -- LED(0) <= clk_out;
    -- LED(1) <= CLK11M0592;
    -- led(2) <= '1';

end architecture ; -- arch

