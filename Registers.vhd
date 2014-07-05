library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Registers is
	port(
		clk : in STD_LOGIC;
		reset: in STD_LOGIC;
		RegReadNumberA : in STD_LOGIC_VECTOR(4 downto 0);
		RegReadNumberB : in STD_LOGIC_VECTOR(4 downto 0);
		RegWrite : in STD_LOGIC;
		RegWriteNumber : in STD_LOGIC_VECTOR(4 downto 0);
		RegWriteValue : in STD_LOGIC_VECTOR(31 downto 0);
		RegWriteByteOnly: in STD_LOGIC;
		RegWriteBytePos: in STD_LOGIC_VECTOR(1 downto 0);
		RegReadSignedMultResult: out STD_LOGIC_VECTOR(63 downto 0);
		RegReadUnsignedMultResult: out STD_LOGIC_VECTOR(63 downto 0);
		RegReadValueA : buffer STD_LOGIC_VECTOR(31 downto 0);
		RegReadValueB : buffer STD_LOGIC_VECTOR(31 downto 0)
		);
end Registers;

architecture Behavioral of Registers is
	type regs is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
	-- signal GPR : regs := (others => (others => '0'));
	signal GPR : regs := (29 => x"807fff00",  -- $sp
						  others => (others => '0'));
	signal realWriteValue: STD_LOGIC_VECTOR(31 downto 0);

component SignedMultAdd port (
    clk : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    sclr : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    c : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    subtract : IN STD_LOGIC;
    p : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    pcout : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
	);
end component;

component UnsignedMultAdd port (
    clk : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    sclr : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    c : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    subtract : IN STD_LOGIC;
    p : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    pcout : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
	);
end component;


	begin

	mul0: SignedMultAdd port map (
		not clk, '1', '0',
		RegReadValueA, RegReadValueB,
		"00", '0',
		RegReadSignedMultResult,
		open
		);

	mul1: UnsignedMultAdd port map (
		not clk, '1', '0',
		RegReadValueA, RegReadValueB,
		"00", '0',
		RegReadUnsignedMultResult,
		open
		);

		realWriteValue(7 downto 0) <= 
			RegWriteValue(31 downto 24) when RegWriteByteOnly = '1' and RegWriteBytePos = "00" else
			RegWriteValue(23 downto 16) when RegWriteByteOnly = '1' and RegWriteBytePos = "01" else
			RegWriteValue(15 downto 8) when RegWriteByteOnly = '1' and RegWriteBytePos = "10" else
			RegWriteValue(7 downto 0);

		with RegWriteByteOnly select
			realWriteValue(31 downto 8) <= (others => '0') when '1',
									       RegWriteValue(31 downto 8) when others;

		process(clk, reset)
		begin
			if reset = '1' then 
				RegReadValueA <= (others => '0');
				RegReadValueB <= (others => '0');
				GPR <= (others => (others => '0'));
				GPR <= (29 => x"807fff00",  -- $sp
 					    others => (others => '0'));
			elsif ( clk'event and clk = '1' ) then
				if ( RegWrite = '1' ) and (RegWriteNumber /= "00000") then
					GPR(to_integer(unsigned(RegWriteNumber))) <= realWriteValue;
				end if;

				if ( RegWrite = '1' ) and (RegWriteNumber /= "00000") and 
						RegReadNumberA = RegWriteNumber then
					RegReadValueA <= realWriteValue;
				else
					RegReadValueA <= GPR(to_integer(unsigned(RegReadNumberA)));
				end if;

				if ( RegWrite = '1' ) and (RegWriteNumber /= "00000") and 
						RegReadNumberB = RegWriteNumber then
					RegReadValueB <= realWriteValue;
				else
					RegReadValueB <= GPR(to_integer(unsigned(RegReadNumberB)));
				end if;

			end if;
		end process;
end Behavioral;
