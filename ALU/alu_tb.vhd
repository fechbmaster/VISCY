-- variable Data_1 : BIT_VECTOR (0 to 3) := ('0','1','0','1');
-- variable Data_2 : BIT_VECTOR (0 to 3) := (1=>'1',0=>'0',3=>'1',2=>'0');
-- Data_Bus <= (15 downto 8 => '0', 7 downto 0 => '1');
-- Data_Bus <= (14 downto 8 => '0', others => '1');


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU_TB is
end ALU_TB;

architecture TESTBENCH of ALU_TB is

  -- Component declaration...
  component ALU is
    port (
			 a : in std_logic_vector (15 downto 0); -- Eingang A
			 b : in std_logic_vector (15 downto 0); -- Eingang B
			 sel : in std_logic_vector (2 downto 0); -- Operation
			 y : out std_logic_vector (15 downto 0); -- Ausgang
			 zero: out std_logic -- gesetzt, falls Eingang B = 0
		);
  end component;


  signal a, b, y : std_logic_vector(15 downto 0);
  signal sel : std_logic_vector(2 downto 0);
  signal zero: std_logic;

begin

  ALU1: ALU port map (a => a, b => b, sel => sel, y => y, zero => zero);
  
  process
  begin  	  				

	for i in 0 to 7 loop	--sel '000' to '111'
		sel <= std_logic_vector(to_unsigned(i, 3));			
					
		for j in -5 to 5 loop	--'a' low values
			a <= std_logic_vector(to_signed(j, 16));		
			
			--'b'  low values		
			for k in -5 to 5 loop
				b <= std_logic_vector(to_signed(k, 16));
				
				wait for 200 ns;
				case sel is
					when "000" => assert y = std_logic_vector(signed(a) + signed(b)) report integer'image(to_integer(signed(a))) & " + " & integer'image(to_integer(signed(b)))  & " = " & integer'image(to_integer(signed(y))) & "; expected: " & integer'image(to_integer(signed(a) + signed(b))); --add
					when "001" => assert y = std_logic_vector(signed(a) - signed(b)) report integer'image(to_integer(signed(a))) & " - " & integer'image(to_integer(signed(b)))  & " = " & integer'image(to_integer(signed(y))) & "; expected: " & integer'image(to_integer(signed(a) + signed(b))); --sub 
					when "010" => assert y = a(14 downto 0) & '0' report integer'image(to_integer(signed(a))) & " << = " & integer'image(to_integer(signed(y))) & "; expected: " & integer'image(to_integer(signed(a(14 downto 0) & '0'))); --Shift left
					when "011" => assert y = a(15) & a(15 downto 1) report integer'image(to_integer(signed(a))) & " >> = " & integer'image(to_integer(signed(y))) & "; expected: " & integer'image(to_integer(signed(a(15) & a(15 downto 1)))); --Shift right
					when "100" => assert y = (a AND b) report integer'image(to_integer(signed(a))) & " AND = " & integer'image(to_integer(signed(y))) & "; expected: " & integer'image(to_integer(signed(a(15) & a(15 downto 1)))); --Shift right
					when "101" => assert y = (a OR b) report "problem with OR"; --OR
					when "110" => assert y = (a XOR b) report "problem with XOR"; --XOR
					when others => assert y = (NOT a) report "problem with NOT"; --NOT
				end case;
				
				if(b = X"0000") then
					assert zero = '1' report "b = 0 but zero is not 1";
				else
					assert zero = '0' report "b != 0 but zero is 1";
				end if;
				
			end loop;
		end loop;			
	end loop;
				
    assert false report "Simulation finished" severity note;
    wait;
  end process;

end architecture;
