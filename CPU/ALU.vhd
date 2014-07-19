library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

entity ALU is
	Port (  A: in STD_LOGIC_VECTOR(31 downto 0);
			B: in STD_LOGIC_VECTOR(31 downto 0);
			op: in STD_LOGIC_VECTOR(3 downto 0);
			result: out STD_LOGIC_VECTOR(31 downto 0)
		);
end ALU;
architecture Behavioral of ALU is
	begin
		process(A,B,op)
		begin
		
		case op is
			when "0000" => --add signed
				result <= STD_LOGIC_VECTOR(signed(A) + signed(B));
				-- if( A(31) = '1' and B(31) = '1' and result(31) = '0' ) then  --overflow
				-- 	result <= (0 => '1',others => '0');
				-- end if;
			when "0001" => --add unsigned
				result <= STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
				-- if( A(31) = '1' and B(31) = '1' and result(31) = '0' ) then  --overflow
				-- 	result <= (0 => '1',others => '0');
				-- end if;
			when "0010" => --sub signed
				result <= STD_LOGIC_VECTOR(signed(A) - signed(B));
			when "0011" => --sub unsigned
				result <= STD_LOGIC_VECTOR(unsigned(A) - unsigned(B));
			when "0100" => --AND
				result <= A and B;
			when "0101" => --OR
				result <= A or B;
			when "0110" => --XOR
				result <= A xor B;
			when "0111" => --NOR
				result <= A nor B;
			when "1000" =>  --isEqual
				if (A = B) then
					result <= (0 => '1', others => '0');
				else
					result <= (others => '0');
				end if;
			when "1001" => --isNotEqual
				if (A /= B) then
					result <= (0 => '1', others => '0');
				else
					result <= (others => '0');
				end if;
			when  "1010" => --compare signed
				-- result <= A - B; --special
				if signed(A) < signed(B) then
					result <= (0 => '1', others => '0');
				else
					result <= (others => '0');			
				end if;
			when "1011" => --compare unsigned
				if( unsigned(A) < unsigned(B) ) then
					result <= (0 => '1', others => '0');
				else
					result <= (others => '0');
				end if;
			when "1100" => --sll
				result <= STD_LOGIC_VECTOR(unsigned(A) sll to_integer(unsigned(B)));
			when "1101" => --srl
				result <= STD_LOGIC_VECTOR(unsigned(A) srl to_integer(signed(B)));
			when "1110" => --sra
				result <= STD_LOGIC_VECTOR(shift_right(signed(A), to_integer(signed(B))));
			when "1111" => --do nothing
				result <= A;
			when others =>
				result <= A;
		end case;
		end process;
end Behavioral;
			