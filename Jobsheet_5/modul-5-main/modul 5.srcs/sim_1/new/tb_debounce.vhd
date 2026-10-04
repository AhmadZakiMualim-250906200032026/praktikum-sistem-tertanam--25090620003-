library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture sim of tb_debounce is
    signal clk     : STD_LOGIC := '0';
    signal btn_in  : STD_LOGIC := '0';
    signal btn_out : STD_LOGIC;
begin
    UUT : entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000,   -- 100 kHz (periode 10 us) :
                      STABLE_MS   => 1 )        -- override biar simulasi cepat
        port map ( clk => clk, btn_in => btn_in, btn_out => btn_out );

    clk <= not clk after 5 us;   -- periode 10 us

    stim : process
    begin
        -- 1) fase "bouncing": transisi cepat, rentang stabil terpanjang 300 us
        --    (< 1 ms) -> btn_out harus TETAP 0
        btn_in <= '1';  wait for 300 us;
        btn_in <= '0';  wait for 200 us;
        btn_in <= '1';  wait for 100 us;
        btn_in <= '0';  wait for 100 us;
        btn_in <= '1';  wait for 250 us;
        assert btn_out = '0'
            report "GAGAL 1: selama noise, btn_out harus tetap 0" severity error;

        -- 2) stabil '1' selama > 1 ms -> btn_out akhirnya = 1
        wait for 2 ms;
        assert btn_out = '1'
            report "GAGAL 2: setelah stabil 1 ms, btn_out harus 1" severity error;

        -- 3) lepas dengan bouncing: rentang stabil terpanjang 300 us
        --    (< 1 ms) -> btn_out harus TETAP 1
        btn_in <= '0'; wait for 200 us;
        btn_in <= '1'; wait for 300 us;
        btn_in <= '0'; wait for 100 us;
        assert btn_out = '1'
            report "GAGAL 3: selama noise saat lepas, btn_out harus tetap 1" severity error;

        -- 4) stabil '0' selama > 1 ms -> btn_out = 0
        wait for 2 ms;
        assert btn_out = '0'
            report "GAGAL 4: setelah stabil 0 selama 1 ms, btn_out harus 0" severity error;

        report "Simulasi debounce selesai.";
        wait;
    end process;
end sim;