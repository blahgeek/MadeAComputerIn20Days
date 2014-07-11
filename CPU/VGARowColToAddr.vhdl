library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity VGARowColToAddr is
  port (
    col: in std_logic_vector(6 downto 0);
    row: in std_logic_vector(4 downto 0);
    addr: out std_logic_vector(11 downto 0)
  ) ;
end entity ; -- VGARowColToAddr

architecture arch of VGARowColToAddr is

    signal row_mul_64: std_logic_vector(11 downto 0);
    signal row_mul_16: std_logic_vector(11 downto 0);

begin

    row_mul_16(3 downto 0) <= (others => '0');
    row_mul_16(11 downto 9) <= (others => '0');
    row_mul_16(8 downto 4) <= row;

    row_mul_64(5 downto 0) <= (others => '0');
    row_mul_64(11) <= '0';
    row_mul_64(10 downto 6) <= row;

    addr <= STD_LOGIC_VECTOR(
        unsigned(row_mul_64) + unsigned(row_mul_16) + unsigned(col));



end architecture ; -- arch
