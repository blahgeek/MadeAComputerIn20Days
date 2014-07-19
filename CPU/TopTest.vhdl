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
    ENET_25M : out std_logic;
    ENET_RESET : out std_logic := '1'); -- reset on 0

end TopTest;


architecture arch of TopTest is

    signal tri_state: std_logic;

    signal real_clock: std_logic := '0';
    signal clk25M: std_logic := '0';

begin

    divider : process(CLK50M)
    begin
        if rising_edge(CLK50M) then
            clk25M <= not clk25M;
        end if;
    end process ; -- divider

    ENET_25M <= clk25M;

    with SW_DIP(2 downto 0) select
        real_clock <= CLK50M when "000",
                      not CLK_From_Key when "010",
                      clk25M when others;

    ENET_RESET <= reset;

    tri_state <= SW_DIP(15);

    with tri_state select
        ENET_D <= SW_DIP(31 downto 16) when '1',
                  (others => 'Z') when others;

    with tri_state select
        LED <= SW_DIP(31 downto 16) when '1',
               ENET_D when others;

    ENET_CS <= '0';
    ENET_CMD <= SW_DIP(7);
    ENET_IOR <= SW_DIP(6);
    ENET_IOW <= SW_DIP(5);

end arch ; -- arch
