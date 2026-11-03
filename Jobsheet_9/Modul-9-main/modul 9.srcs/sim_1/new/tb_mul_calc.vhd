library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mul_calc is
end tb_mul_calc;

architecture sim of tb_mul_calc is
    signal sw        : std_logic_vector(7 downto 0) := (others => '0');
    signal prod_q4_4 : std_logic_vector(7 downto 0);
    signal digits    : std_logic_vector(15 downto 0);
begin
    uut: entity work.mul_calc
        port map (sw => sw, prod_q4_4 => prod_q4_4, digits => digits);

    process
        procedure cek(s : std_logic_vector(7 downto 0);
                      p : std_logic_vector(7 downto 0);
                      d : std_logic_vector(15 downto 0);
                      nama : string) is
        begin
            sw <= s; wait for 10 ns;
            assert prod_q4_4 = p report "GAGAL (Q4.4): " & nama severity error;
            assert digits = d    report "GAGAL (digit): " & nama severity error;
        end procedure;
    begin
        cek(x"00", x"00", x"0000", "0 x 0 = 0.00");
        cek(x"44", x"10", x"0100", "1.0 x 1.0 = 1.00");
        cek(x"88", x"40", x"0400", "2.0 x 2.0 = 4.00");
        cek(x"86", x"30", x"0300", "2.0 x 1.5 = 3.00");
        cek(x"66", x"24", x"0225", "1.5 x 1.5 = 2.25");
        cek(x"F4", x"3C", x"0375", "3.75 x 1.0 = 3.75");
        cek(x"FF", x"E1", x"1406", "3.75 x 3.75 = 14.06");
        report "Simulasi perkalian selesai" severity note;
        wait;
    end process;
end sim;