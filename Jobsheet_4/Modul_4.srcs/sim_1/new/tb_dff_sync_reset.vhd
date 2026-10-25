library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_dff_sync_reset is
end tb_dff_sync_reset;

architecture sim of tb_dff_sync_reset is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    signal d   : STD_LOGIC := '0';
    signal q   : STD_LOGIC;
begin
    UUT : entity work.dff_sync_reset
        port map ( clk => clk, rst => rst, d => d, q => q );

    -- generator clock: berubah tiap 10 ns -> periode 20 ns
    clk <= not clk after 10 ns;

    stim : process
    begin
        -- 1) rst aktif: q tetap 0 walaupun d sudah '1'
        d <= '1';                       -- t=0
        wait for 25 ns;                 -- t=25 (tepi t=10 lewat, rst masih 1)
        assert q = '0'
            report "GAGAL 1: saat rst=1, q harus tetap 0" severity error;

        -- 2) rst dilepas -> q menyalin d pada tepi berikutnya
        rst <= '0'; wait for 30 ns;     -- t=55 (tepi t=30,50 dgn rst=0)
        assert q = '1'
            report "GAGAL 2: setelah rst dilepas, q harus menyalin d" severity error;

        -- 3) d berubah di TENGAH periode -> q TIDAK langsung berubah
        d <= '0'; wait for 5 ns;        -- t=60 (tepi berikutnya di 70)
        assert q = '1'
            report "GAGAL 3: q tidak boleh berubah sebelum tepi clock" severity error;
        wait for 15 ns;                 -- t=75 (tepi t=70 lewat)
        assert q = '0'
            report "GAGAL 4: q menyalin d tepat pada tepi clock" severity error;

        -- 4) variasi normal
        d <= '1'; wait for 25 ns;       -- t=100 (tepi t=90)
        assert q = '1'
            report "GAGAL 5: q harus menyalin d" severity error;

        -- 5) reset SYNCHRONOUS: aktif tapi belum berlaku sebelum tepi
        rst <= '1'; d <= '0'; wait for 5 ns;  -- t=105 (tepi berikutnya di 110)
        assert q = '1'
            report "GAGAL 6: reset sync tidak berlaku sebelum tepi clock" severity error;
        wait for 15 ns;                 -- t=120 (tepi t=110 dgn rst=1)
        assert q = '0'
            report "GAGAL 7: q harus 0 setelah tepi dengan rst=1" severity error;

        report "Simulasi DFF selesai.";
        wait;
    end process;
end sim;