
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LOOPBACK is
    port 
    (  
        -- General
        CLOCK                   :   in      std_logic;
        RESET                   :   in      std_logic;    
        RX                      :   in      std_logic;
        TX                      :   out     std_logic;
        -- sram
        base_ram_addr : buffer  STD_LOGIC_VECTOR (19 downto 0);
        base_ram_data : inout  STD_LOGIC_VECTOR (31 downto 0);
        base_ram_CE : out  STD_LOGIC;
        base_ram_OE : out  STD_LOGIC;
        base_ram_WE : out  STD_LOGIC;
        -- debug
        led : out STD_LOGIC_VECTOR(7 downto 0)
    );
end LOOPBACK;

architecture RTL of LOOPBACK is
    
    constant BAUD_RATE              : positive := 115200;
    constant CLOCK_FREQUENCY        : positive := 11059200;

    component UART is
        generic (
                BAUD_RATE           : positive;
                CLOCK_FREQUENCY     : positive
            );
        port (  -- General
                CLOCK               :   in      std_logic;
                RESET               :   in      std_logic;    
                DATA_STREAM_IN      :   in      std_logic_vector(7 downto 0);
                DATA_STREAM_IN_STB  :   in      std_logic;
                DATA_STREAM_IN_ACK  :   out     std_logic;
                DATA_STREAM_OUT     :   out     std_logic_vector(7 downto 0);
                DATA_STREAM_OUT_STB :   out     std_logic;
                DATA_STREAM_OUT_ACK :   in      std_logic;
                TX                  :   out     std_logic;
                RX                  :   in      std_logic
             );
    end component UART;

    signal uart_data_in             : std_logic_vector(7 downto 0);
    signal uart_data_out            : std_logic_vector(7 downto 0);
    signal uart_data_in_stb         : std_logic;
    signal uart_data_in_ack         : std_logic;
    signal uart_data_out_stb        : std_logic;
    signal uart_data_out_ack        : std_logic;

    signal read_or_write: std_logic ; -- 0 for read
    signal base_addr : std_logic_vector(6 downto 0);
    signal data_buf : std_logic_vector(31 downto 0);

    type state_type is (idle, check_command, start_write, 
        start_read, read_send, write_on, write_done, 
        read_wait_send, inc_addr, write_ack);
    signal state: state_type := idle;
  
begin

 --   led <= "01010001";

    UART_inst1 : UART
    generic map (
            BAUD_RATE           => BAUD_RATE,
            CLOCK_FREQUENCY     => CLOCK_FREQUENCY
    )
    port map    (  
            -- General
            CLOCK               => CLOCK,
            RESET               => RESET,
            DATA_STREAM_IN      => uart_data_in,
            DATA_STREAM_IN_STB  => uart_data_in_stb,
            DATA_STREAM_IN_ACK  => uart_data_in_ack,
            DATA_STREAM_OUT     => uart_data_out,
            DATA_STREAM_OUT_STB => uart_data_out_stb,
            DATA_STREAM_OUT_ACK => uart_data_out_ack,
            TX                  => TX,
            RX                  => RX
    );
    
    process (CLOCK)
        variable count : integer := 0;
    begin
        if (CLOCK'event and CLOCK = '1') then
            if RESET = '1' then
			    led <= "11111111";
                state <= idle;
                uart_data_in_stb <= '0';
                uart_data_out_ack <= '0';
                base_ram_CE <= '0'; -- enable sram
                base_ram_OE <= '0'; -- read always on
                base_ram_WE <= '1'; -- disable write
                base_ram_data <= (others => 'Z');  -- for output
                count := 0;
            else
                case( state ) is
                    when idle =>
                        led <= "11110000";
                        if uart_data_out_stb = '1' then
                            read_or_write <= uart_data_out(7);
                            base_addr <= uart_data_out(6 downto 0);
                            uart_data_out_ack <= '1';
                            state <= check_command;
                        end if;  
                    when check_command =>
                        led <= "11100000";
                        base_ram_addr(19 downto 13) <= base_addr;
                        base_ram_addr(12 downto 0) <= (others => '0');
                        uart_data_out_ack <= '0';
                        if read_or_write = '0' then -- read
                            state <= start_read;
                        else
                            state <= start_write;
                        end if;
                    when start_read =>
                        led <= "11000000";
                        data_buf <= base_ram_data;
                        state <= read_send;
                    when read_send =>
                        led <= "10000000";
                        count := count + 1;
                        uart_data_in <= data_buf(31 downto 24);
                        uart_data_in_stb <= '1'; -- send it
                        state <= read_wait_send;
                    when read_wait_send =>
                        led <= "00000001";
                        if uart_data_in_ack = '1' then
                            uart_data_in_stb <= '0';
                            data_buf(31 downto 8) <= data_buf(23 downto 0);
                            if count = 4 then
                                state <= inc_addr;
                            else
                                state <= read_send;
                            end if;
                        end if;
                    when inc_addr =>
                        led <= "00000010";
                        count := 0;
                        if base_ram_addr(12 downto 0) = "1111111111111" then  -- better method?
                            state <= idle;
                        else
                            base_ram_addr <= std_logic_vector(unsigned(base_ram_addr)+1);
                            if read_or_write = '0' then
                                state <= start_read;
                            else
                                state <= start_write;
                            end if;
                        end if;
                    when start_write =>
                        led <= "00000011";
                        if uart_data_out_stb = '1' then
                            uart_data_out_ack <= '1';
                            data_buf <= data_buf(23 downto 0) & uart_data_out;
                            state <= write_ack;
                            count := count + 1;
                        end if;
                    when write_ack =>
                        led <= "00000111";
                        uart_data_out_ack <= '0';
                        if count = 4 then
                            base_ram_WE <= '0';
                            base_ram_data <= data_buf;
                            state <= write_on;
                        else
                            state <= start_write;
                        end if;
                    when write_on =>
                        led <= "00000101";
                        base_ram_WE <= '1';
                        state <= write_done;
                    when write_done =>
                        led <= "00001001";
                        base_ram_data <= (others => 'Z');
                        uart_data_out_ack <= '0';
                        state <= inc_addr;
                end case ;
            end if;
        end if;
    end process;
            
end RTL;
