
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP is
port 
(  
        -- General
        clk110592                :   in      std_logic;
        rst              :   in      std_logic;    
        inter_conn_in       : in std_logic_vector(4 downto 0);
        inter_conn_out      : out std_logic_vector(4 downto 0);

        base_ram_addr : buffer  STD_LOGIC_VECTOR (19 downto 0);
        base_ram_data : inout  STD_LOGIC_VECTOR (31 downto 0);
        base_ram_CE : out  STD_LOGIC;
        base_ram_OE : out  STD_LOGIC;
        base_ram_WE : out  STD_LOGIC;

        led: out std_logic_vector(7 downto 0)

        );
end TOP;

architecture RTL of TOP is

    ----------------------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------------------
    
    component LOOPBACK is
    port 
    (  
            -- General
            CLOCK                   :   in      std_logic;
            RESET                   :   in      std_logic;    
            RX                      :   in      std_logic;
            TX                      :   out     std_logic;

            base_ram_addr : buffer  STD_LOGIC_VECTOR (19 downto 0);
            base_ram_data : inout  STD_LOGIC_VECTOR (31 downto 0);
            base_ram_CE : out  STD_LOGIC;
            base_ram_OE : out  STD_LOGIC;
            base_ram_WE : out  STD_LOGIC;
            led  : out std_logic_vector(7 downto 0)
            );
end component LOOPBACK;

    ----------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------

    signal tx, rx, rx_sync, reset, reset_sync : std_logic;
    
    begin


    inter_conn_out(4 downto 1) <= (others => '0');
    ----------------------------------------------------------------------------
    -- Loopback instantiation
    ----------------------------------------------------------------------------

    LOOPBACK_inst1 : LOOPBACK
    port map    (  
            -- General
            CLOCK       => clk110592,
            RESET       => reset, 
            RX          => rx,
            TX          => tx,
            base_ram_WE => base_ram_WE,
            base_ram_OE => base_ram_OE,
            base_ram_CE => base_ram_CE,
            base_ram_data => base_ram_data,
            base_ram_addr => base_ram_addr,
            led => led
            );
    
    ----------------------------------------------------------------------------
    -- Deglitch inputs
    ----------------------------------------------------------------------------
    
    DEGLITCH : process (clk110592)
        begin
            if rising_edge(clk110592) then
            rx_sync         <= inter_conn_in(0);
            rx              <= rx_sync;
            reset_sync      <= not rst;
            reset           <= reset_sync;
            inter_conn_out(0)   <= tx;
        end if;
    end process;
end RTL;