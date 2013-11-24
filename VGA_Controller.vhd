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

    type data_type is array(0 to 2439) of std_logic_vector(6 downto 0);

    signal data: data_type:= (others => (others => '0'));

--VGA
    signal CLK25M   : std_logic := '0';
    signal CLK  : std_logic := '0';
    signal rt,gt,bt : std_logic_vector (2 downto 0);
    signal x        : std_logic_vector (9 downto 0);
    signal y        : std_logic_vector (8 downto 0);

    signal in_y_shift_6: std_logic_vector(10 downto 0);
    signal in_y_shift_4: std_logic_vector(8 downto 0);

    signal x_div    : std_logic_vector(6 downto 0);
    signal x_remain: std_logic_vector(2 downto 0);
    signal y_div    : std_logic_vector(4 downto 0);
    signal y_remain: std_logic_vector(3 downto 0);
    signal y_div_shift_6: std_logic_vector(10 downto 0);
    signal y_div_shift_4: std_logic_vector(8 downto 0);

    signal font_addr: std_logic_vector(10 downto 0);
    signal font_data: std_logic_vector(7 downto 0);

    signal now_char: std_logic_vector(6 downto 0);
    
begin


    x_remain <= x(2 downto 0);
    y_remain <= y(3 downto 0);
    x_div <= x(9 downto 3);
    y_div <= y(8 downto 4);
    y_div_shift_6(5 downto 0) <= (others => '0');
    y_div_shift_6(10 downto 6) <= y_div;
    y_div_shift_4(3 downto 0) <= (others => '0');
    y_div_shift_4(8 downto 4) <= y_div;
    now_char <= data(to_integer(unsigned(x_div)+unsigned(y_div_shift_6)+unsigned(y_div_shift_4)));

    font_addr(3 downto 0) <= y_remain;
    font_addr(10 downto 4) <= now_char;

    font0: font_rom port map(CLK_in, font_addr, font_data);

    in_y_shift_6(5 downto 0) <= (others => '0');
    in_y_shift_6(10 downto 6) <= in_y;
    in_y_shift_4(3 downto 0) <= (others => '0');
    in_y_shift_4(8 downto 4) <= in_y;

    process (in_set, reset) begin
        if reset = '1' then
            data <= (others => (others => '0'));
        elsif rising_edge(in_set) then
            data(to_integer(unsigned(in_x)+unsigned(in_y_shift_6)+unsigned(in_y_shift_4))) <= in_data;
        end if;
    end process;

    process (CLK_in) begin
        if rising_edge(CLK_in) then
            CLK25M <= not CLK25M;
        end if;
    end process;

    VGA_CLK <= CLK25M;
    CLK <= CLK25M;
    
    process (CLK, reset)
    begin
        if reset = '1' then
            x <= (others => '0');
        elsif rising_edge(CLK) then
            if unsigned(x) = 799 then
                x <= (others => '0');
            else
                x <= std_logic_vector(unsigned(x) + 1);
            end if;
        end if;
    end process;

     process (CLK, reset) begin
        if reset = '1' then
            y <= (others => '0');
        elsif rising_edge(CLK) then
            if unsigned(x) = 799 then
                if unsigned(y) = 524 then
                    y <= (others => '0');
                else
                    y <= std_logic_vector(unsigned(y) + 1);
                end if;
            end if;
        end if;
     end process;
 
     process (CLK, reset)
     begin
          if reset = '1' then
           hs <= '1';
          elsif rising_edge(CLK) then
            if unsigned(x) >= 662 and unsigned(x) < 755 then
                hs <= '0';
            else
                hs <= '1';
            end if;
          end if;
     end process;
 
     process (CLK, reset)
     begin
        if reset = '1' then
            vs <= '1';
        elsif rising_edge(CLK) then
            if unsigned(y) >= 491 and unsigned(y) < 493 then
                vs <= '0';
            else
                vs <= '1';
            end if;
        end if;
     end process;

    process(x,y)
    begin
        if unsigned(x) > 640 or unsigned(y) > 480 then
            rt <= (others=>'0');
            gt <= (others=>'0');
            bt <= (others=>'0');
        else
            rt <= (others => font_data(to_integer(7-unsigned(x_remain))));
            gt <= (others => font_data(to_integer(7-unsigned(x_remain))));
            bt <= (others => font_data(to_integer(7-unsigned(x_remain))));
            -- rt <= (others => '1');
            -- if unsigned(y) < 10 or unsigned(y) > 470 then
            --     gt <= (others => '1');
            -- else
            --     gt <= (others => '0');
            -- end if;
            -- if unsigned(x) < 10 or unsigned(x) > 630 then
            --     bt <= (others => '1');
            -- else
            --     bt <= (others => '0');
            -- end if;
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
