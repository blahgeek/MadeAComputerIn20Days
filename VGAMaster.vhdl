library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity VGAMaster is
  port (
    hs, vs: out std_logic := '0';
    red, green, blue: out std_logic_vector(2 downto 0) := (others => '0');

    in_x: in std_logic_vector(6 downto 0); -- 80
    in_y: in std_logic_vector(4 downto 0); -- 30
    in_data: in std_logic_vector(6 downto 0); -- ascii
    in_set: in std_logic;

    reset: in std_logic;
    CLK50M: in std_logic;
  ) ;
end entity ; -- VGAMaster

architecture arch of VGAMaster is

    signal x: std_logic_vector(9 downto 0);
    signal y: std_logic_vector(8 downto 0);

begin

end architecture ; -- arch