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

    ENET_D: inout std_logic_vector(15 downto 0) := (others => 'Z');
    ENET_CMD: out std_logic := '0';
    ENET_CS : out std_logic := '0'; -- always selected
    ENET_INT : in std_logic;
    ENET_IOR : out std_logic := '1';
    ENET_IOW : out std_logic := '1';
    ENET_25M : out std_logic;
    ENET_RESET : out std_logic := '1'; -- reset on 0

    VGA_Blue: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Green: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Red: out std_logic_vector(2 downto 0) := (others => '0');
    VGA_Vhync: buffer std_logic := '0';
    VGA_Hhync: buffer std_logic := '0' );

end TOP;

architecture arch of TOP is

component VGAConsoleMemory PORT (
    a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dpra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    dpo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component;

signal VGA_write_addr: std_logic_vector(11 downto 0);
signal VGA_write_data: std_logic_vector(7 downto 0);
signal VGA_read_addr: std_logic_vector(11 downto 0);
signal VGA_write_we: STD_LOGIC := '0';
signal VGA_read_data: STD_LOGIC_VECTOR(7 downto 0);

 component InterruptHandler port (
    clock: in std_logic;
    reset: in std_logic;

    mask: in std_logic_vector(7 downto 0);
    globalmask: in STD_LOGIC;

    timer_int: in std_logic;
    uart_int: in std_logic;

    int: out std_logic;
    int_numbers: out std_logic_vector(7 downto 0)
  );
  end component;

signal timer_int: std_logic;

signal Interrupt_mask: std_logic_vector(7 downto 0);
signal Interrupt_globalmask: STD_LOGIC;
signal Interrupt_int: std_logic;
signal Interrupt_numbers: std_logic_vector(7 downto 0);


component CoreRom port (
    a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end component;

component FetcherAndRegister port (

    debug: out std_logic_vector(7 downto 0) := (others => '0');

    PC: in std_logic_vector(31 downto 0);
    RAM_select: in std_logic;
    clock: in std_logic;
    reset: in std_logic;

    timer_int: out std_logic := '0';

    Interrupt_mask: out std_logic_vector(7 downto 0);
    Interrupt_globalmask: out STD_LOGIC;
    Interrupt_int: in std_logic := '0';
    Interrupt_numbers: in std_logic_vector(7 downto 0);

    TLB_set_do: out std_logic := '0';
    TLB_set_index: out std_logic_vector(2 downto 0);
    TLB_set_entry: out std_logic_vector(63 downto 0);

    TLB_data_exception: in std_logic;
    TLB_data_exception_read_or_write: in std_logic;
    TLB_data_addr: in std_logic_vector(31 downto 0);

    TLB_instruction_bad: in std_logic;

    hold: buffer std_logic:= '0';

    BACK_REG_write: in std_logic;
    BACK_REG_write_addr: in std_logic_vector(4 downto 0);
    BACK_REG_write_data: in std_logic_vector(31 downto 0);
    BACK_REG_write_byte_only: in std_logic;
    BACK_REG_write_byte_pos: in std_logic_vector(1 downto 0);

    BASERAM_data: in std_logic_vector(31 downto 0);
    EXTRAM_data: in std_logic_vector(31 downto 0);

    BIOS_data: in std_logic_vector(31 downto 0);

    ALU_operator: out std_logic_vector(3 downto 0);
    ALU_numA: out std_logic_vector(31 downto 0);
    ALU_numB: out std_logic_vector(31 downto 0);

    JUMP_true: out std_logic;
    JUMP_addr: out std_logic_vector(31 downto 0);

    MEM_read: out std_logic;
    MEM_write: out std_logic;
    MEM_write_byte_only: out std_logic;
    MEM_data: out std_logic_vector(31 downto 0);

    hold_from_memory: in std_logic;

    REG_write: out std_logic;
    REG_write_byte_only: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0)  -- we have 32 registers
  ) ;
 end component ; -- FetcherAndRegister 

component ALUWrapper port (
    clock: in std_logic;
    reset: in std_logic;

    hold_from_memory: in std_logic;

    ALU_operator: in std_logic_vector(3 downto 0) ;
    ALU_numA: in std_logic_vector(31 downto 0) ;
    ALU_numB: in std_logic_vector(31 downto 0) ;

    ALU_output: out std_logic_vector(31 downto 0) := (others => '0');
    ALU_output_after_TLB: out std_logic_vector(31 downto 0) := (others => '0');

    TLB_virt: out std_logic_vector(19 downto 0);
    TLB_real: in std_logic_vector(19 downto 0);
    TLB_bad: in std_logic;

    TLB_exception: out std_logic:= '0';
    TLB_exception_read_or_write: out std_logic:= '0'; -- 0 for read

    -- forward
    in_MEM_read: in std_logic ;
    in_MEM_write: in std_logic ;
    in_MEM_write_byte_only: in std_logic;
    in_MEM_data: in std_logic_vector(31 downto 0);
    in_REG_write: in std_logic ;
    in_REG_write_byte_only: in std_logic;
    in_REG_write_addr: in std_logic_vector(4 downto 0);

    MEM_read: out std_logic := '0';
    MEM_write: out std_logic := '0';
    MEM_write_byte_only: out std_logic := '0';
    MEM_data: out std_logic_vector(31 downto 0);
    REG_write: out std_logic := '0';
    REG_write_byte_only: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0)
  ) ;
end component; -- ALUWrapper

    signal TLB_data_exception: std_logic := '0';
    signal TLB_data_exception_read_or_write: std_logic; -- 0 for read

component Memory port (
    clock: in std_logic;
    reset: in std_logic;

    hold_from_memory: out std_logic;

    ALU_output: in std_logic_vector(31 downto 0);
    ALU_output_after_TLB: in std_logic_vector(31 downto 0);
    MEM_read: in std_logic;
    MEM_write: in std_logic;
    MEM_write_byte_only: in std_logic;
    MEM_data: in std_logic_vector(31 downto 0);

    MEM_output: out std_logic_vector(31 downto 0) := (others => '0');

    in_REG_write: in std_logic;
    in_REG_write_addr: in std_logic_vector(4 downto 0);
    in_REG_write_byte_only: in std_logic;
    REG_write: out std_logic := '0';
    REG_write_addr: out std_logic_vector(4 downto 0) := (others => '0');
    REG_write_byte_only: out std_logic := '0';
    REG_write_byte_pos: out std_logic_vector(1 downto 0) := "00";

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

component PCdecider port (
    clock: in std_logic;
    reset: in std_logic;

    reset_on_bios: in std_logic;

    hold: in std_logic;

    JUMP_true: in std_logic;
    JUMP_addr: in std_logic_vector(31 downto 0);

    BASERAM_addr: inout std_logic_vector(19 downto 0);
    EXTRAM_addr: inout std_logic_vector(19 downto 0);

    TLB_virt: out std_logic_vector(19 downto 0);
    TLB_real: in std_logic_vector(19 downto 0);
    RAM_select: out std_logic;

    PC: buffer std_logic_vector(31 downto 0)
  ) ;
end component; -- PCdecider

signal BIOS_data: std_logic_vector(31 downto 0) := (others => '0');
signal BIOS_addr: std_logic_vector(11 downto 0) := (others => '0');

signal A_RAM_SELECT : std_logic;

component UART is
    Generic (
            BAUD_RATE           : positive;
            CLOCK_FREQUENCY     : positive
        );
    Port (
            CLOCK           :   in      std_logic;
            RESET               :   in      std_logic;
            DATA_STREAM_IN      :   in      std_logic_vector(7 downto 0);
            DATA_STREAM_IN_STB  :   in      std_logic;
            DATA_STREAM_IN_ACK  :   out     std_logic := '0';
            DATA_STREAM_OUT     :   out     std_logic_vector(7 downto 0);
            DATA_STREAM_OUT_STB :   out     std_logic;
            DATA_STREAM_OUT_ACK :   in      std_logic;
            TX                  :   out     std_logic;
            RX                  :   in      std_logic  -- Async Receive
         );
end component;

component TLB is
  port (
    clock: in std_logic;
    reset: in std_logic;

    instruction_virt_addr: in std_logic_vector(19 downto 0);
    instruction_real_addr: out std_logic_vector(19 downto 0);
    instruction_bad: out std_logic:= '0';

    data_virt_addr: in std_logic_vector(19 downto 0);
    data_real_addr: out std_logic_vector(19 downto 0);
    data_bad: out std_logic:= '0';

    set_do: in std_logic;
    set_index: in std_logic_vector(2 downto 0);
    set_entry: in std_logic_vector(63 downto 0)
  ) ;
end component ; -- TLB

    signal TLB_clock: std_logic;
    signal instruction_virt_addr, instruction_real_addr: std_logic_vector(19 downto 0);
    signal data_virt_addr, data_real_addr: std_logic_vector(19 downto 0);
    signal instruction_bad, data_bad: std_logic;
    signal TLB_set_do: std_logic := '0';
    signal TLB_set_index: std_logic_vector(2 downto 0);
    signal TLB_set_entry: std_logic_vector(63 downto 0);

component VGA_Controller is
    port (
        VGA_CLK : out std_logic;
        hs,vs   : buffer std_logic;
        oRed    : out std_logic_vector (2 downto 0);
        oGreen  : out std_logic_vector (2 downto 0);
        oBlue   : out std_logic_vector (2 downto 0);

        col: out std_logic_vector(6 downto 0);
        row: out std_logic_vector(4 downto 0);
        data: in std_logic_vector(7 downto 0); -- ascii

        reset   : in  std_logic;
        CLK_in  : in  std_logic -- 50M
    );      
end component;

    signal VGA_col: STD_LOGIC_VECTOR(6 downto 0);
    signal VGA_row: STD_LOGIC_VECTOR(4 downto 0);

    -- reset is '1' if not clicked, that's not what we want
    signal real_reset: std_logic := '0';
    signal real_clock: std_logic := '0';
    signal clk25M: std_logic := '0';
    signal clk1M8432: std_logic := '0';

    signal clk_count: std_logic(2 downto 0) := "000";

    signal PC: std_logic_vector(31 downto 0) := (others => '0');
    signal A_HOLD: std_logic := '0';

    signal ALU_operator: std_logic_vector(3 downto 0) := "1111";
    signal ALU_numA: std_logic_vector(31 downto 0) := (others => '0');
    signal ALU_numB: std_logic_vector(31 downto 0) := (others => '0');
    signal ALU_output: std_logic_vector(31 downto 0) := (others => '0');
    signal ALU_output_after_TLB: std_logic_vector(31 downto 0) := (others => '0');

    signal JUMP_true: std_logic := '0'; 
    signal JUMP_addr: std_logic_vector(31 downto 0) := (others => '0'); 

    signal A_MEM_read: std_logic := '0'; 
    signal A_MEM_write: std_logic := '0'; 
    signal A_MEM_write_byte_only: std_logic:= '0';
    signal A_MEM_data: std_logic_vector(31 downto 0) := (others => '0');
    signal B_MEM_read: std_logic := '0'; 
    signal B_MEM_write: std_logic := '0'; 
    signal B_MEM_write_byte_only: std_logic := '0';
    signal B_MEM_data: std_logic_vector(31 downto 0) := (others => '0');

    signal MEM_output: std_logic_vector(31 downto 0) := (others => '0');

    signal A_REG_write: std_logic := '0';
    signal A_REG_write_addr: std_logic_vector(4 downto 0) := (others => '0');
    signal A_REG_write_byte_only: std_logic := '0';
    signal B_REG_write: std_logic := '0';
    signal B_REG_write_addr: std_logic_vector(4 downto 0) := (others => '0');
    signal B_REG_write_byte_only: std_logic := '0';
    signal C_REG_write: std_logic := '0';
    signal C_REG_write_addr: std_logic_vector(4 downto 0) := (others => '0');
    signal C_REG_write_byte_only: std_logic := '0';

    signal REG_write_byte_pos: std_logic_vector(1 downto 0) := "00";

    signal s_state : std_logic_vector(1 downto 0) := "00";

    signal s_rx, s_tx: std_logic;
    signal uart_data_in: std_logic_vector(7 downto 0);
    signal uart_data_in_stb, uart_data_in_ack: std_logic;
    signal uart_data_out: std_logic_vector(7 downto 0);
    signal uart_data_out_stb, uart_data_out_ack: std_logic;

    signal hold_from_memory: std_logic := '0';

component VGARowColToAddr is
  port (
    col: in std_logic_vector(6 downto 0);
    row: in std_logic_vector(4 downto 0);
    addr: out std_logic_vector(11 downto 0)
  ) ;
end component ; -- VGARowColToAddr

    signal VGA_mem_col: std_logic_vector(6 downto 0);
    signal VGA_mem_row: std_logic_vector(4 downto 0);
    signal VGA_mem_data: std_logic_vector(6 downto 0);

begin

    VGAConsolemem0: VGAConsoleMemory port map (
        VGA_write_addr, VGA_write_data,
        VGA_read_addr, real_clock,
        VGA_write_we, open, VGA_read_data
        );

    VGA_write_data(6 downto 0) <= VGA_mem_data;
    VGA_write_data(7) <= '0';


    InterConn(0) <= 'Z'; -- in
    s_rx <= InterConn(0);
    InterConn(5) <= s_tx;

    uart0: UART generic map (BAUD_RATE => 115200, CLOCK_FREQUENCY => 1843200)
                port map (clk1M8432, real_reset, 
                          uart_data_in, uart_data_in_stb, uart_data_in_ack,
                          uart_data_out, uart_data_out_stb, uart_data_out_ack,
                          s_tx, s_rx);

    vga0: VGA_Controller port map (
        open, VGA_Hhync, VGA_Vhync,
        VGA_Red, VGA_Green, VGA_Blue,
        VGA_col, VGA_row, VGA_read_data,
        real_reset, CLK50M
        );

    rowcol2addr0: VGARowColToAddr port map (
        VGA_col, VGA_row, VGA_read_addr
        );
    rowcol2addr1: VGARowColToAddr port map (
        VGA_mem_col, VGA_mem_row, VGA_write_addr
        );

    -- vga0: VGA_Controller port map(
    --     open, VGA_Hhync, VGA_Vhync, VGA_Red, VGA_Green, VGA_Blue,
    --     VGA_in_x, VGA_in_y, VGA_in_data, VGA_in_set, real_reset, s_clk50m);

    divider : process(CLK50M)
    begin
        if rising_edge(CLK50M) then
            clk25M <= not clk25M;
        end if;
    end process ; -- divider

    process(CLK11M0592) begin
        if rising_edge(CLK11M0592) then
            case( clk_count ) is
                when "000" | "001" | "010" =>
                    clk1M8432 <= '0';
                    clk_count <= std_logic_vector(unsigned(clk_count)+1);
                when "011" | "100" =>
                    clk1M8432 <= '1';
                    clk_count <= std_logic_vector(unsigned(clk_count)+1);
                when others =>
                    clk1M8432 <= '1';
                    clk_count <= "000";
            end case ;
        end if;
    end process;

    real_reset <= not reset;

    ENET_RESET <= reset; -- ENET_RESET is valid on '0'

    -- with SW_DIP(2 downto 0) select
    --     real_clock <= CLK50M when "000",
    --                   not CLK_From_Key when "010",
    --                   CLK11M0592 when "101",
    --                   clk25M when others;

    real_clock <= not CLK_From_Key when (SW_DIP(2 downto 0) = "010" 
                                            or (SW_DIP(6) = '1' and PC(15 downto 0) = SW_DIP(31 downto 16))) else
                  CLK50M when SW_DIP(2 downto 0) = "000" else
                  CLK11M0592 when SW_DIP(2 downto 0) = "101" else
                  clk25M;

    TLB_clock <= not real_clock;
    ENET_25M <= clk25M;

    BaseRamOE <= '0';
    BaseRamCE <= '0';
    ExtRamCE <= '0';
    ExtRamOE <= '0';

tlb0: TLB port map (
    TLB_clock, real_reset,
    instruction_virt_addr, instruction_real_addr, instruction_bad,
    data_virt_addr, data_real_addr, data_bad,
    TLB_set_do, TLB_set_index, TLB_set_entry);

FetcherAndRegister0: FetcherAndRegister port map (
    open,
    PC, A_RAM_SELECT, real_clock, real_reset, 
    timer_int, Interrupt_mask, Interrupt_globalmask,
    Interrupt_int, Interrupt_numbers,
    TLB_set_do, TLB_set_index, TLB_set_entry,
    TLB_data_exception, TLB_data_exception_read_or_write,
    ALU_output,
    instruction_bad,
    A_HOLD,
    C_REG_write,
    C_REG_write_addr,
    MEM_output, -- reg write data
    C_REG_write_byte_only,
    REG_write_byte_pos,
    BaseRamData,  -- data from sw
    ExtRamData,
    BIOS_data,
    ALU_operator, ALU_numA, ALU_numB,
    JUMP_true, JUMP_addr,
    A_MEM_read, A_MEM_write, A_MEM_write_byte_only, A_MEM_data, hold_from_memory,
    A_REG_write, A_REG_write_byte_only, A_REG_write_addr
    );

  int_handler0: InterruptHandler port map (
    real_clock, real_reset, 
    Interrupt_mask, -- IM7-0
    Interrupt_globalmask,
    timer_int,
    uart_data_out_stb,
    Interrupt_int, Interrupt_numbers
  );

-- LED(0) <= instruction_bad;
-- LED(1) <= data_bad;
-- LED(7 downto 2) <= instruction_virt_addr(19 downto 14);

ALUWrapper0: ALUWrapper port map (
    real_clock, real_reset, hold_from_memory,
    ALU_operator, ALU_numA, ALU_numB, ALU_output, ALU_output_after_TLB,
    data_virt_addr, data_real_addr, data_bad, 
    TLB_data_exception, TLB_data_exception_read_or_write,
    A_MEM_read, A_MEM_write, A_MEM_write_byte_only,
    A_MEM_data, 
    A_REG_write, A_REG_write_byte_only, A_REG_write_addr,
    B_MEM_read, B_MEM_write, B_MEM_write_byte_only,
    B_MEM_data, 
    B_REG_write, B_REG_write_byte_only, B_REG_write_addr);

Mem0: Memory port map (
    real_clock, real_reset, hold_from_memory,
    ALU_output, ALU_output_after_TLB, 
    B_MEM_read, B_MEM_write, B_MEM_write_byte_only,
    B_MEM_data,
    MEM_output, 
    B_REG_write, B_REG_write_addr, B_REG_write_byte_only,
    C_REG_write, C_REG_write_addr, C_REG_write_byte_only,
    REG_write_byte_pos,
    BaseRamWE, BaseRamAddr, BaseRamData,
    ExtRamWE, ExtRamAddr, ExtRamData,
    uart_data_in, uart_data_in_stb, uart_data_in_ack,
    uart_data_out, uart_data_out_stb, uart_data_out_ack,
    VGA_mem_col, VGA_mem_row, VGA_mem_data, VGA_write_we,
    -- open, open, open, open, -- no VGA
    -- VGA_in_x, VGA_in_y, VGA_in_data, VGA_in_set,
    ENET_D, ENET_CMD, ENET_IOR, ENET_IOW, ENET_INT, -- ethernet
    DYP0, DYP1, open);

PC0: PCdecider port map(
    real_clock, real_reset, 
    SW_DIP(7),
    A_HOLD,
    JUMP_true,
    JUMP_addr,
    BaseRamAddr, ExtRamAddr,
    instruction_virt_addr, instruction_real_addr,
    A_RAM_SELECT,
    PC);

BIOS_addr <= BaseRamAddr(11 downto 0);

bios: CoreRom port map (
    BIOS_addr, BIOS_data);

-- debug

    LED <= BIOS_data(31 downto 16);

end arch;
