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
    ALU_output_after_TLB: in std_logic_vector(31 downto 0);
    MEM_read: in std_logic;
    MEM_write: in std_logic;
    MEM_data: in std_logic_vector(31 downto 0);
    MEM_write_byte_only: in std_logic;

    MEM_output: out std_logic_vector(31 downto 0) := (others => '0');

    in_REG_write: in std_logic;
    in_REG_write_addr: in std_logic_vector(4 downto 0);
    in_REG_write_byte_only: in std_logic;
    REG_write: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0) := (others => '0');
    REG_write_byte_only: out std_logic := '0';

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
end component ; -- Memory

    signal clock: std_logic;
    signal MEM_read, MEM_write: std_logic;
    signal MEM_write_byte_only: std_logic;
    signal ALU_output, ALU_output_after_TLB, MEM_data, MEM_output: std_logic_vector(31 downto 0);
    signal BASERAM_addr, EXTRAM_addr: std_logic_vector(19 downto 0);
    signal BASERAM_data, EXTRAM_data: std_logic_vector(31 downto 0);
    signal BASERAM_WE, EXTRAM_WE: std_logic;
    signal ENET_D: std_logic_vector(15 downto 0);

    constant clk_period :time :=20 ns;

begin

    instance: Memory port map (
        clock, '0',
        ALU_output, ALU_output_after_TLB, 
        MEM_read, MEM_write, MEM_data, MEM_write_byte_only,
        MEM_output, '0', "00000", '0', open, open, open, 
        BASERAM_WE, BASERAM_addr, BASERAM_data,
        EXTRAM_WE, EXTRAM_addr, EXTRAM_data,
        open, open, '0',
        "00000000", '0', open,
        open, open, open, open,
        ENET_D, open, open, open, '0',
        open, open, open);

    process begin
        clock <= '0';
        MEM_read <= '0';
        MEM_write <= '1';
        MEM_write_byte_only <= '1';
        MEM_data <= x"00000023";
        ALU_output <= x"90000000";
        ALU_output_after_TLB <= x"DEADBEEF";
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
        MEM_read <= '0';
        MEM_write <= '0';
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
