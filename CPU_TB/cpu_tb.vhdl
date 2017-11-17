LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

--USE IEEE.std_logic_unsigned.ALL;

USE IEEE.numeric_std.ALL;





ENTITY cpu_tb IS

END cpu_tb;





ARCHITECTURE behavior OF cpu_tb IS



	-- Component Declaration for the Unit Under Test (UUT)...

	COMPONENT CPU

		PORT (

			clk, reset, ready : IN std_logic;

			rd, wr : OUT std_logic;

			adr : OUT std_logic_vector(15 downto 0);

			data : INOUT std_logic_vector(15 downto 0)

		);

	END COMPONENT;

	

	-- Configuration...

    for uut: CPU use entity WORK.CPU(RTL);

	

	-- Signals...

	SIGNAL clk, reset, ready, rd, wr: std_logic;

	SIGNAL adr, data: std_logic_vector (15 downto 0);

	

	type t_memory is array (0 to 259) of STD_LOGIC_VECTOR(15 downto 0);

    signal mem_content: t_memory;

    

  

	-- Parameters...

	constant clk_period: time := 10 ns;

	constant mem_delay: time := 25 ns;

	

	-- Memory content (created by viscy2l) ...

  type t_memory is array (0 to 263) of STD_LOGIC_VECTOR(15 downto 0);

  signal mem_content: t_memory := (

      16#0000# => "0100100000000000",   -- LDIH  r0, 0x00   ; => 1111111100000000

      16#0001# => "0100000000000000",   -- LDIL  r0, 0x00   ; => 1111111111111111

      16#0002# => "0100100100000000",   -- LDIH  r1, 0x00   ; => 1111111100000000

      16#0003# => "0100000100000000",   -- LDIL  r1, 0x00   ; => 1111111111111111

      16#0004# => "0100101100000000",   -- LDIH  r3, 0x00   ; => 1111111100000000

      16#0005# => "0100001100000000",   -- LDIL  r3, 0x00   ; => 1111111111111111

      16#0006# => "0011000000000000",   -- XOR   r0, r0, r0 ; Nur '0' in r0

      16#0007# => "0100000000001000",   -- LDIL  r0, 8      ; 1. Wert in r0

      16#0008# => "0011000100100100",   -- XOR   r1, r1, r1

      16#0009# => "0100000100000100",   -- LDIL  r1, 4

      16#000a# => "0011001101101100",   -- XOR   r3, r3, r3 ; Ergebnis Register leeren

      16#000b# => "0000001100000100",   -- ADD   r3, r0, r1 ; Addieren, r3 = r0 + r1     => 12

      16#000c# => "0011001101101100",   -- XOR   r3, r3, r3

      16#000d# => "0000101100000100",   -- SUB   r3, r0, r1 ; Subtrahieren, r3 = r0 - r1 => 4

      16#000e# => "0011001101101100",   -- XOR   r3, r3, r3

      16#000f# => "0001001100000000",   -- SAL   r3, r0     ; Shift nach links           => 16

      16#0010# => "0011001101101100",   -- XOR   r3, r3, r3

      16#0011# => "0001101100000000",   -- SAR   r3, r0     ; Shift nach rechts          => 4

      16#0012# => "0011001101101100",   -- XOR   r3, r3, r3

      16#0013# => "0100101111111111",   -- LDIH  r3, 0xFF   ; => 1111111100000000

      16#0014# => "0100001111111111",   -- LDIL  r3, 0xFF   ; => 1111111111111111

      16#0015# => "0010001100000100",   -- AND   r3, r0, r1 ; => 0

      16#0016# => "0011001101101100",   -- XOR   r3, r3, r3

      16#0017# => "0010101100000100",   -- OR    r3, r0, r1 ; => 12

      16#0018# => "0011001101101100",   -- XOR   r3, r3, r3

      16#0019# => "0011001100000100",   -- XOR   r3, r0, r1 ; => 12

      16#001a# => "0011001101101100",   -- XOR   r3, r3, r3

      16#001b# => "0011101100000000",   -- NOT   r3, r0     ; => 1111111111110111

      16#001c# => "1000100000000000",   -- halt ; Prozessor anhalten

      16#0100# => "0000000000000000",   -- result: .res 8 ; 8 Worte reservieren

      16#0101# => "0000000000000000",

      16#0102# => "0000000000000000",

      16#0103# => "0000000000000000",

      16#0104# => "0000000000000000",

      16#0105# => "0000000000000000",

      16#0106# => "0000000000000000",

      16#0107# => "0000000000000000",

      others => "UUUUUUUUUUUUUUUU"

    );

	

	

	BEGIN

	-- Instantiate the Unit Under Test (UUT)

	uut: CPU PORT MAP(

		clk => clk, reset => reset,

		rd => rd, wr => wr, ready => ready,

		adr => adr, data => data

	);

	

	-- Process to simulate the memory behavior...

	memory: process

	begin

		data <= "ZZZZZZZZZZZZZZZZ";

		ready <= '0';

		wait on rd, wr;

		if rd = '1' then

			wait for mem_delay;

			data <= mem_content (to_integer ( unsigned('0' & adr)));

			ready <= '1';

			wait until rd = '0';

			data <= "ZZZZZZZZZZZZZZZZ";

			wait for mem_delay;

			ready <= '0';

		elsif wr = '1' then

			wait for mem_delay;

			mem_content (to_integer ( unsigned('0' & adr))) <= data;

			ready <= '1';

			wait until wr = '0';

			wait for mem_delay;

			ready <= '0';

		end if;

	end process;

	

	-- Main testbench process...

	tb : PROCESS

	

		procedure run_cycle is

		begin

			clk <= '0';

			wait for clk_period / 2;

			clk <= '1';

			wait for clk_period / 2;

		end procedure;

	

	BEGIN	

	

	-- sinnvolles Hauptprogramm überlegen

	reset <= '1';

	run_cycle;

	reset <= '0';

	for i in 0 to 500 loop

		run_cycle;

	end loop;

	

	wait; -- wait forever (stop simulation)

	END PROCESS;

END;
