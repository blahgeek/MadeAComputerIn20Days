library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity FetcherAndRegisterTestbench is

end entity ; -- FetcherAndRegisterTestbench


architecture arch of FetcherAndRegisterTestbench is

component FetcherAndRegister port (
    PC: in std_logic_vector(31 downto 0);
    RAM_select: in std_logic;
    clock: in std_logic;
    reset: in std_logic;
    hold: buffer std_logic:= '0';

    BACK_REG_write: in std_logic;
    BACK_REG_write_addr: in std_logic_vector(4 downto 0);
    BACK_REG_write_data: in std_logic_vector(31 downto 0);

    BASERAM_data: in std_logic_vector(31 downto 0);
    EXTRAM_data: in std_logic_vector(31 downto 0);

    ALU_operator: out std_logic_vector(3 downto 0);
    ALU_numA: out std_logic_vector(31 downto 0);
    ALU_numB: out std_logic_vector(31 downto 0);

    JUMP_true: out std_logic;
    JUMP_addr: out std_logic_vector(31 downto 0);

    MEM_read: out std_logic;
    MEM_write: out std_logic;
    MEM_data: out std_logic_vector(31 downto 0);

    REG_write: out std_logic;
    REG_write_addr: out std_logic_vector(4 downto 0)  -- we have 32 registers
  ) ;
 end component ; -- FetcherAndRegister 

  signal clock: std_logic := '0';

  signal ALU_operator:  std_logic_vector(3 downto 0);
  signal ALU_numA:  std_logic_vector(31 downto 0);
  signal ALU_numB:  std_logic_vector(31 downto 0);

  signal JUMP_true:  std_logic;
  signal JUMP_addr:  std_logic_vector(31 downto 0);

  signal MEM_read:  std_logic;
  signal MEM_write:  std_logic;
  signal MEM_data:  std_logic_vector(31 downto 0);

  signal REG_write:  std_logic;
  signal REG_write_addr:  std_logic_vector(4 downto 0);  -- we have 32 registers

  signal BACK_REG_write : std_logic;
  signal BACK_REG_write_addr: std_logic_vector(4 downto 0);
  signal BACK_REG_write_data: std_logic_vector(31 downto 0);

  constant clk_period :time :=20 ns;
  signal data: std_logic_vector(31 downto 0);

begin

    instance: FetcherAndRegister port map (
        PC => x"0000001c", 
        RAM_select => '0',
        clock => clock, 
        reset => '0',
        hold=>open,

        BACK_REG_write => BACK_REG_write,
        BACK_REG_write_addr => BACK_REG_write_addr,
        BACK_REG_write_data => BACK_REG_write_data,

        BASERAM_data => data, -- instruction
        EXTRAM_data => x"00000000",

        ALU_operator => ALU_operator,
        ALU_numA => ALU_numA,
        ALU_numB => ALU_numB,

        JUMP_true => JUMP_true,
        JUMP_addr => JUMP_addr,

        MEM_read => MEM_read,
        MEM_write => MEM_write,
        MEM_data => MEM_data,

        REG_write => REG_write,
        REG_write_addr => REG_write_addr

        );

    process begin
        BACK_REG_write <= '1';
        BACK_REG_write_addr <= "01010"; -- 10
        BACK_REG_write_data <= x"DEADBEEF";
        data <= "01000000100000010111100000000000"; -- mtc
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        BACK_REG_write <= '0';
        data(31 downto 0) <= "00010101011010101111111111111110"; -- bne 10 11
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
        clock <= '0';
        wait for clk_period/2;
        wait;
    end process;

end architecture ; -- arch