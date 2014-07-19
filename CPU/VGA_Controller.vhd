library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Controller is
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
end entity VGA_Controller;

architecture behave of VGA_Controller is

component CoreFontRom port (
    a: IN std_logic_vector(10 downto 0);
    spo: out std_logic_vector(7 downto 0)
);
end component;

    signal font_rom_addr: std_logic_vector(10 downto 0);
    signal font_rom_data: std_logic_vector(7 downto 0);
    

--VGA
    signal rt,gt,bt : std_logic_vector (2 downto 0);
    signal x        : std_logic_vector (9 downto 0);
    signal y        : std_logic_vector (9 downto 0);

    signal data_bit: std_logic;

    signal state : std_logic := '0';
    
begin

    fontrom0: CoreFontRom port map (font_rom_addr, font_rom_data);

    font_rom_addr(3 downto 0) <= y(3 downto 0);
    font_rom_addr(10 downto 4) <= data(6 downto 0); -- ascii
    data_bit <= font_rom_data(to_integer(7-unsigned(x(2 downto 0))));

    col <= x(9 downto 3);
    row <= y(8 downto 4);

    process (CLK_in, reset) begin
        if reset = '1' then
            state <= '0';
            x <= (others => '0');
            y <= (others => '0');
            hs <= '1';
            vs <= '1';
        elsif rising_edge(CLK_in) then
            case( state ) is
                when '0' =>
                    if unsigned(x) = 799 then
                        x <= (others => '0');
                        if unsigned(y) = 524 then
                            y <= (others => '0');
                        else
                            y <= std_logic_vector(unsigned(y) + 1);
                        end if;
                    else
                        x <= std_logic_vector(unsigned(x) + 1);
                    end if;
                    state <= '1';

                when others =>
                    if unsigned(x) >= 662 and unsigned(x) < 755 then
                        hs <= '0';
                    else
                        hs <= '1';
                    end if;
                    if unsigned(y) >= 491 and unsigned(y) < 493 then
                        vs <= '0';
                    else
                        vs <= '1';
                    end if;
                    if unsigned(x) > 640 or unsigned(y) > 480 then
                        rt <= (others=>'0');
                        gt <= (others=>'0');
                        bt <= (others=>'0');
                    else
                        rt <= (others => data_bit);
                        gt <= (others => data_bit);
                        bt <= (others => '1');  -- so that it's not black... = =
                    end if;
                    state <= '0';
            end case ;
        end if;
    end process;

    process (hs, vs, rt, gt, bt)
    begin
        if hs = '1' and vs = '1' then
            oRed    <= rt;
            oGreen  <= gt;
            oBlue   <= bt;
        else
            oRed    <= (others => '0');
            oGreen  <= (others => '0');
            oBlue   <= (others => '0');
        end if;
    end process;

end behave;
