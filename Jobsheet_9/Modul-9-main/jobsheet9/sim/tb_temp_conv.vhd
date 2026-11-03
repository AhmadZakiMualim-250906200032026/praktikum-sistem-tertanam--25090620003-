library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_temp_conv is
end tb_temp_conv;

architecture sim of tb_temp_conv is
    signal sw        : std_logic_vector(11 downto 0) := (others => '0');
    signal temp_q8_8 : std_logic_vector(15 downto 0);
    signal digits    : std_logic_vector(15 downto 0);
begin
    uut: entity work.temp_conv
        port map (sw => sw, temp_q8_8 => temp_q8_8, digits => digits);

    process
    begin
        sw <= x"000"; wait for 10 ns;
        assert digits = x"000C" report "GAGAL: 0 -> 0.0C" severity error;

        sw <= x"400"; wait for 10 ns;
        assert temp_q8_8 = x"1900" report "GAGAL: 1024 -> 25.0 (Q8.8)" severity error;
        assert digits = x"250C" report "GAGAL: 1024 -> 25.0C" severity error;

        sw <= x"800"; wait for 10 ns;
        assert temp_q8_8 = x"3200" report "GAGAL: 2048 -> 50.0 (Q8.8)" severity error;
        assert digits = x"500C" report "GAGAL: 2048 -> 50.0C" severity error;

        sw <= x"FFF"; wait for 10 ns;
        assert digits = x"999C" report "GAGAL: 4095 -> 99.9C" severity error;

        report "Simulasi konversi selesai" severity note;
        wait;
    end process;
end sim;
