library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity pass is
  port (
    RXD1: in std_logic;
    TXD1: out std_logic;
    inter_conn_0_4: out std_logic_vector(4 downto 0);
    inter_conn_5_9: in std_logic_vector(4 downto 0)
  ) ;
end entity ; -- pass

architecture arch of pass is

begin

    inter_conn_0_4(0) <= RXD1;
    inter_conn_0_4(4 downto 1) <= (others => '0');
    TXD1 <= inter_conn_5_9(0);

end architecture ; -- arch