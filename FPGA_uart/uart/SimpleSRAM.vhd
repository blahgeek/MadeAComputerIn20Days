library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--    before write and read: be sure READY is 0
-- Write: give me DATA_WRITE, ADDR, rise STB_WRITE, 
--        wait until READY is set to 1, lower STB_WRITE
-- Read:  give me ADDR, rise STB_READ, wait until READY is 1, 
--        lower STD_READ, read from DATA_READ

entity SimpleSRAM is
    Port (  DATA_WRITE   : in STD_LOGIC_VECTOR(31 downto 0);
            DATA_READ   : out STD_LOGIC_VECTOR(31 downto 0);
            READY       : out STD_LOGIC;
            ADDR        : in STD_LOGIC_VECTOR(19 downto 0);
            STB_WRITE   : in STD_LOGIC;
            STB_READ    : in STD_LOGIC;

	        clk: in STD_LOGIC;
            -- to SRAM
           base_ram_addr : out  STD_LOGIC_VECTOR (19 downto 0);
           base_ram_data : inout  STD_LOGIC_VECTOR (31 downto 0);
           base_ram_CE : out  STD_LOGIC;
           base_ram_OE : out  STD_LOGIC;
           base_ram_WE : out  STD_LOGIC);
end SimpleSRAM;

architecture Behavioral of SimpleSRAM is

	type state_type is (write_start, write_1, read_start, read_1, idle);
	signal state: state_type := idle;
	
begin

	process (clk)
	begin
		if (clk'event and clk = '1') then
			case state is
				when idle =>
					base_ram_addr <= (others => '0');
					base_ram_OE <= '1';  -- disable read
					base_ram_CE <= '0';  
					base_ram_WE <= '1';  -- disable write
                    base_ram_data <= (others => 'Z');
                    READY <= '0';
                    if (STB_WRITE = '1') then
                        state <= write_start;
                    elsif (STB_READ = '1') then 
                        state <= read_start;
                    else
                        state <= idle;
					end if;
				when write_start =>
					base_ram_WE <= '0';  -- enable write
                    base_ram_addr <= ADDR;
                    base_ram_data <= DATA_WRITE;
                    READY <= '1';
                    state <= write_1;
				when write_1 =>
					base_ram_WE <= '1';  -- write now
					state <= idle;  -- write done
                when read_start =>
                    base_ram_addr <= ADDR;
                    base_ram_OE <= '0';
                    READY <= '1';
                    state <= read_1;
                when read_1 =>
                    DATA_READ <= base_ram_data;
                    state <= idle;
			end case;
		end if;
	end process;
					

end Behavioral;

