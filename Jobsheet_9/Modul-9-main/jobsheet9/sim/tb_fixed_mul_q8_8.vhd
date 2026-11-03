library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_fixed_mul_q8_8 is
end tb_fixed_mul_q8_8;

architecture sim of tb_fixed_mul_q8_8 is
    signal a, b, result : std_logic_vector(15 downto 0) := (others => '0');
begin
    uut: entity work.fixed_mul_q8_8
        port map (a => a, b => b, result => result);

    process
        procedure cek(av, bv, ekspektasi : std_logic_vector(15 downto 0);
                      nama : string) is
        begin
            a <= av; b <= bv;
            wait for 10 ns;
            assert result = ekspektasi
                report "GAGAL: " & nama severity error;
        end procedure;
    begin
        cek(x"0200", x"0300", x"0600", "2.0 x 3.0 = 6.0");
        cek(x"0180", x"0180", x"0240", "1.5 x 1.5 = 2.25");
        cek(x"0080", x"0080", x"0040", "0.5 x 0.5 = 0.25");
        cek(x"0A00", x"0C80", x"7D00", "10.0 x 12.5 = 125.0");
        cek(x"0100", x"0100", x"0100", "1.0 x 1.0 = 1.0");
        cek(x"0000", x"0500", x"0000", "0 x 5.0 = 0");
        report "Simulasi selesai, cek Tcl Console untuk error" severity note;
        wait;
    end process;
end sim;
