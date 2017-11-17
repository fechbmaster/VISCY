library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
port 	( a: in std_logic_vector (15 downto 0);
		  b : in std_logic_vector(15 downto 0);
		  sel : in std_logic_vector (2 downto 0);
		  y: out std_logic_vector (15 downto 0);
		  zero: out std_logic);
end ALU;
 
architecture Behavioral of ALU is
begin

	process (sel, a, b)
	begin
		case sel is
			when "000" => y <= std_logic_vector(unsigned(a) + unsigned(b)); -- ADD
			when "001" => y <= std_logic_vector(unsigned(a) - unsigned(b)); -- SUB
			when "011" => y(15) <= a(15); y(14 downto 0) <= a(15 downto 1); -- SAR
			when "010" => y(15 downto 1) <= a(14 downto 0); y(0) <= '0'; -- SAL
			when "100" => y <= a AND b; -- AND
			when "101" => y <= a(15 downto 0) OR b(15 downto 0); -- OR
			when "110" => y <= a XOR b; -- XOR
			when others => y <= NOT a; -- NOT

		end case;
				
		if (b = X"0000") then
			zero <= '1';
		else
			zero <= '0';
		end if;
	end process;
	
end Behavioral;





