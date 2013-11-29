library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MemoryTestbench is
end entity ; -- MemoryTestbench

architecture arch of MemoryTestbench is

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

    DYP0: out std_logic_vector(6 downto 0) := (others => '0');
    DYP1: out std_logic_vector(6 downto 0) := (others => '0');
    LED: out std_logic_vector(15 downto 0) := (others => '0')
  ) ;
end component ; -- Memory

    signal clock: std_logic;
    signal MEM_read, MEM_write: std_logic;
    signal ALU_output, MEM_data, MEM_output: std_logic_vector(31 downto 0);
    signal BASERAM_addr, EXTRAM_addr: std_logic_vector(19 downto 0);
    signal BASERAM_data, EXTRAM_data: std_logic_vector(31 downto 0);
    signal VGA_x: std_logic_vector(6 downto 0);
    signal VGA_y: std_logic_vector(4 downto 0);
    signal VGA_data: std_logic_vector(6 downto 0);
    signal VGA_set: std_logic;

    signal UART_DATA_SEND_STB: std_logic;

    constant clk_period :time :=20 ns;

begin

    instance: Memory port map (
        clock, '0',
        ALU_output, MEM_read, MEM_write, MEM_data,
        MEM_output, '0', "00000", open, open,
        open, BASERAM_addr, BASERAM_data,
        open, EXTRAM_addr, EXTRAM_data,
        open, UART_DATA_SEND_STB, '0',
        "00000000", '0', open,
        VGA_x, VGA_y, VGA_data, VGA_set,
        open, open, open);

    process begin
        clock <= '0';
        MEM_read <= '0';
        MEM_write <= '1';
        MEM_data <= x"00000023";
        ALU_output <= x"90000000";
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