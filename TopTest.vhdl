library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopTest is
port (
    reset: in std_logic;
    CLK_From_Key: in std_logic;
    CLK11M0592: in std_logic;
    CLK50M: in std_logic;
    SW_DIP: in std_logic_vector(31 downto 0);

    LED: out std_logic_vector(15 downto 0) := (others => '0');

    ENET_D: inout std_logic_vector(15 downto 0) := (others => 'Z');
    ENET_CMD: out std_logic := '0';
    ENET_CS : out std_logic := '0'; -- always selected
    ENET_INT : in std_logic;
    ENET_IOR : out std_logic := '1';
    ENET_IOW : out std_logic := '1';
    ENET_RESET : out std_logic := '1'); -- reset on 0

end TopTest;


architecture arch of TopTest is

    type state_type is (s0, s1, s2, s3);
    signal state: state_type := s0;

    signal real_clock: std_logic := '0';
    signal clk25M: std_logic := '0';

begin

    divider : process(CLK50M)
    begin
        if rising_edge(CLK50M) then
            clk25M <= not clk25M;
        end if;
    end process ; -- divider

    with SW_DIP(2 downto 0) select
        real_clock <= CLK50M when "000",
                      not CLK_From_Key when "010",
                      clk25M when others;

    ENET_RESET <= reset;

    process(real_clock, reset) begin
        if reset = '0' then
            ENET_IOR <= '1';
            ENET_IOW <= '1';
            ENET_D <= (others => 'Z');
            state <= s0;
        elsif rising_edge(real_clock) then
            case( state ) is
                when s0 =>
                    ENET_CMD <= '0'; -- IO
                    ENET_IOW <= '0';
                    ENET_D <= SW_DIP(31 downto 16);
                    LED(15 downto 14) <= "00";
                    state <= s1;
                when s1 =>
                    ENET_IOW <= '1';
                    LED(15 downto 14) <= "01";
                    state <= s2;
                when s2 =>
                    ENET_D <= (others => 'Z');
                    ENET_CMD <= '1'; -- data
                    ENET_IOR <= '0';
                    LED(15 downto 14) <= "10";
                    state <= s3;
                when s3 =>
                    LED(7 downto 0) <= ENET_D(7 downto 0);
                    ENET_IOR <= '1';
                    LED(15 downto 14) <= "11";
                    state <= s0;
            
                when others =>
                    state <= s0;
            
            end case ;
        end if;
    end process;

end arch ; -- arch
