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

        in_x:   in std_logic_vector(6 downto 0);
        in_y:   in std_logic_vector(4 downto 0);
        in_data:in std_logic_vector(6 downto 0); -- ascii
        in_set: in std_logic;

        reset   : in  std_logic;
        CLK_in  : in  std_logic -- 50M
    );      
end entity VGA_Controller;

architecture behave of VGA_Controller is
component font_rom port(
      clk: in std_logic;
      addr: in std_logic_vector(10 downto 0);
      data: out std_logic_vector(7 downto 0)
   );
end component;

    type data_type is array(0 to 2399) of std_logic_vector(6 downto 0);

    signal data: data_type:= (others => (others => '0'));

--VGA
    signal not_CLK  : std_logic := '0';
    signal rt,gt,bt : std_logic_vector (2 downto 0);
    signal x        : std_logic_vector (9 downto 0);
    signal y        : std_logic_vector (9 downto 0);

    signal font_addr: std_logic_vector(10 downto 0);
    signal font_data: std_logic_vector(7 downto 0);

    signal state : std_logic := '0';
    
begin

    not_CLK <= not CLK_in;

    font_addr(3 downto 0) <= y(3 downto 0);
    font_addr(10 downto 4) <= data(to_integer(unsigned(x(9 downto 3))+unsigned(y(9 downto 4))*80));

    font0: font_rom port map(not_CLK, font_addr, font_data);

    process (in_set, reset) begin
        if reset = '1' then
            data <= (others => (others => '0'));
        elsif rising_edge(in_set) then
            data(to_integer(unsigned(in_x)+unsigned(in_y)*80)) <= in_data;
        end if;
    end process;

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
                        rt <= (others => font_data(to_integer(7-unsigned(x(2 downto 0)))));
                        gt <= (others => font_data(to_integer(7-unsigned(x(2 downto 0)))));
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
