library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_leading_one_detector is
end tb_leading_one_detector;

architecture sim of tb_leading_one_detector is
    signal din   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal pos   : STD_LOGIC_VECTOR(2 downto 0);
    signal valid : STD_LOGIC;
begin
    UUT : entity work.leading_one_detector       -- "unit under test"
        generic map ( WIDTH => 8 )
        port map   ( din => din, pos => pos, valid => valid );

    stim : process
    begin
        -- Kasus 1: tidak ada bit '1' sama sekali
        din <= "00000000"; wait for 10 ns;
        assert valid = '0'
            report "GAGAL 1: input 00000000 harus valid='0'" severity error;

        -- Kasus 2: bit '1' di posisi 0
        din <= "00000001"; wait for 10 ns;
        assert (valid = '1' and pos = "000")
            report "GAGAL 2: harus pos=000 valid='1'" severity error;

        -- Kasus 3: bit '1' di posisi 7
        din <= "10000000"; wait for 10 ns;
        assert (valid = '1' and pos = "111")
            report "GAGAL 3: harus pos=111 valid='1'" severity error;

        -- Kasus 4: beberapa bit '1' -> ambil yang paling kiri (posisi 5)
        din <= "00100100"; wait for 10 ns;
        assert (valid = '1' and pos = "101")
            report "GAGAL 4: harus pos=101" severity error;

        -- Kasus 5: bit '1' di posisi 1
        din <= "00000010"; wait for 10 ns;
        assert (valid = '1' and pos = "001")
            report "GAGAL 5: harus pos=001" severity error;

        -- Kasus 6: semua bit '1'
        din <= "11111111"; wait for 10 ns;
        assert (valid = '1' and pos = "111")
            report "GAGAL 6: harus pos=111" severity error;

        report "Simulasi selesai. Tidak ada GAGAL = semua lulus.";
        wait;
    end process;
end sim;