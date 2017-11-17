library IEEE;
use IEEE.std_logic_1164.all; -- Typen & Fkt. für mehrwertige Logik
use IEEE.numeric_std.all; -- arithmetische Operationen mit mehrwertiger Logik

entity REGFILE_TB is
end REGFILE_TB;

architecture TESTBENCH1 of REGFILE_TB is

    -- Deklaration der Komponente Register-File
    component REGFILE is
        port (
            clk: in std_logic;
            out0_data: out std_logic_vector (15 downto 0); -- Datenausgang 0
            out0_sel: in std_logic_vector (2 downto 0); -- Register-Nr. 0
            out1_data: out std_logic_vector (15 downto 0); -- Datenausgang 1
            out1_sel: in std_logic_vector (2 downto 0); -- Register-Nr. 1
            in_data: in std_logic_vector (15 downto 0); -- Dateneingang
            in_sel: in std_logic_vector (2 downto 0); -- Register-Wahl
            load_lo, load_hi: in std_logic -- Register laden
        );
    end component;

    -- Konfiguration
    for IMPL: REGFILE use entity WORK.REGFILE(RTL);

    -- Interne Signale
    signal clk, load_lo, load_hi: std_logic;
    signal out0_sel, out1_sel, in_sel: std_logic_vector (2 downto 0);
    signal out0_data, out1_data, in_data: std_logic_vector (15 downto 0);

begin

    -- Instanziierung Register-File
    IMPL: REGFILE port map (
        clk => clk,
        out0_data => out0_data,
        out0_sel => out0_sel,
        out1_data => out1_data,
        out1_sel => out1_sel,
        in_data => in_data,
        in_sel => in_sel,
        load_lo => load_lo,
        load_hi => load_hi
    );

    -- Hauptprozess
    process
        type t_regfile is array (0 to 7) of std_logic_vector (15 downto 0);
        variable test, actual, expected_lo, expected_hi: t_regfile;

        procedure run_cycle is
        begin
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end procedure;

        procedure init_register is
        begin
            run_cycle;
            load_lo <= '1';
            load_hi <= '1';
            in_data <= "0000000000000000"; -- 16 Bit
            for i in 0 to 7 loop
                in_sel <= std_logic_vector (to_unsigned (i, 3));
                run_cycle;
            end loop;
        end procedure;
    begin

        -- Testdaten
        test(0)(15 downto 0) := "1000000000000001";
        test(1)(15 downto 0) := "0100000000000010";
        test(2)(15 downto 0) := "0010000000000100";
        test(3)(15 downto 0) := "0001000000001000";
        test(4)(15 downto 0) := "0000100000010000";
        test(5)(15 downto 0) := "0000010000100000";
        test(6)(15 downto 0) := "0000001001000000";
        test(7)(15 downto 0) := "0000000110000000";

        expected_lo(0)(15 downto 0) := "0000000000000001";
        expected_lo(1)(15 downto 0) := "0000000000000010";
        expected_lo(2)(15 downto 0) := "0000000000000100";
        expected_lo(3)(15 downto 0) := "0000000000001000";
        expected_lo(4)(15 downto 0) := "0000000000010000";
        expected_lo(5)(15 downto 0) := "0000000000100000";
        expected_lo(6)(15 downto 0) := "0000000001000000";
        expected_lo(7)(15 downto 0) := "0000000010000000";

        expected_hi(0)(15 downto 0) := "1000000000000000";
        expected_hi(1)(15 downto 0) := "0100000000000000";
        expected_hi(2)(15 downto 0) := "0010000000000000";
        expected_hi(3)(15 downto 0) := "0001000000000000";
        expected_hi(4)(15 downto 0) := "0000100000000000";
        expected_hi(5)(15 downto 0) := "0000010000000000";
        expected_hi(6)(15 downto 0) := "0000001000000000";
        expected_hi(7)(15 downto 0) := "0000000100000000";

        -- Initialisierung der Ausgabe-Selektoren
        out0_sel <= std_logic_vector (to_unsigned (0, 3));
        out1_sel <= std_logic_vector (to_unsigned (0, 3));

        -- Test der Ladefunktionalität (Low-Byte)
        init_register;
        load_lo <= '1';
        load_hi <= '0';
        for i in 0 to 7 loop
            in_sel <= std_logic_vector (to_unsigned (i, 3));
            in_data <= test(i);
            run_cycle;
        end loop;
        load_lo <= '0';
        load_hi <= '0';
        for i in 0 to 7 loop
            out0_sel <= std_logic_vector (to_unsigned (i, 3));
            out1_sel <= std_logic_vector (to_unsigned (i, 3));
            run_cycle;
            assert out0_data = expected_lo(i) report "Ausgang 0: Low-Byte konnte nicht erfolgreich geladen werden!";
            assert out1_data = expected_lo(i) report "Ausgang 1: Low-Byte konnte nicht erfolgreich geladen werden!";
        end loop;
        for i in 0 to 7 loop
            out0_sel <= std_logic_vector (to_unsigned (i, 3));
            out1_sel <= std_logic_vector (to_unsigned (7 - i, 3));
            run_cycle;
            assert out0_data = expected_lo(i) report "Ausgang 0: Low-Byte konnte nicht erfolgreich geladen werden!";
            assert out1_data = expected_lo(7 - i) report "Ausgang 1: Low-Byte konnte nicht erfolgreich geladen werden!";
        end loop;

        -- Test der Ladefunktionalität (High-Byte)
        init_register;
        load_lo <= '0';
        load_hi <= '1';
        for i in 0 to 7 loop
            in_sel <= std_logic_vector (to_unsigned (i, 3));
            in_data <= test(i);
            run_cycle;
        end loop;
        load_lo <= '0';
        load_hi <= '0';
        for i in 0 to 7 loop
            out0_sel <= std_logic_vector (to_unsigned (i, 3));
            out1_sel <= std_logic_vector (to_unsigned (i, 3));
            run_cycle;
            assert out0_data = expected_hi(i) report "Ausgang 0: High-Byte konnte nicht erfolgreich geladen werden!";
            assert out1_data = expected_hi(i) report "Ausgang 1: High-Byte konnte nicht erfolgreich geladen werden!";
        end loop;
        for i in 0 to 7 loop
            out0_sel <= std_logic_vector (to_unsigned (i, 3));
            out1_sel <= std_logic_vector (to_unsigned (7 - i, 3));
            run_cycle;
            assert out0_data = expected_hi(i) report "Ausgang 0: High-Byte nicht erfolgreich geladen werden!";
            assert out1_data = expected_hi(7 - i) report "Ausgang 1: High-Byte konnte nicht erfolgreich geladen werden!";
        end loop;

        -- Test der Ladefunktionalität (Low-Byte & High-Byte)
        init_register;
        load_lo <= '1';
        load_hi <= '1';
        for i in 0 to 7 loop
            in_sel <= std_logic_vector (to_unsigned (i, 3));
            in_data <= test(i);
            out0_sel <= std_logic_vector (to_unsigned (i, 3));
            out1_sel <= std_logic_vector (to_unsigned (i, 3));
            run_cycle;
            assert out0_data = test(i) report "Ausgang 0: Low-Byte oder High-Byte konnte nicht erfolgreich geladen werden!";
            assert out1_data = test(i) report "Ausgang 1: Low-Byte oder High-Byte konnte nicht erfolgreich geladen werden!";
        end loop;

        wait;
    end process;

end architecture;
