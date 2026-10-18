----------------------------------------------------------------------------------
-- Jobsheet 7 - Testbench untuk traffic_light_fsm (VERSI + Tugas 1 & 2)
-- 'tick' dibangkitkan manual: tiap tick='1' dianggap mewakili 1 detik berlalu.
-- sw = "0000" -> durasi hijau = 5 detik (biar siklus penuh cepat terlihat di simulasi)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_fsm_tb is
end traffic_light_fsm_tb;

architecture sim of traffic_light_fsm_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk  : STD_LOGIC := '0';
    signal rst  : STD_LOGIC := '0';
    signal tick : STD_LOGIC := '0';
    signal sw   : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- hijau = 5 detik
    signal led  : STD_LOGIC_VECTOR(5 downto 0);

begin

    DUT : entity work.traffic_light_fsm
        port map ( clk => clk, rst => rst, tick => tick, sw => sw, led => led );

    -- Pembangkit clock (hanya untuk menggerakkan register, bukan representasi detik asli)
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Stimulus
    stim_process : process
    begin
        rst <= '1';
        wait for CLK_PERIOD*2;
        rst <= '0';
        wait for CLK_PERIOD*2;

        -- Dengan sw="0000" -> hijau=5s, kuning=3s, all_red=1s
        -- 1 siklus penuh = 5+3+1+5+3+1 = 18 tick. Jalankan 25 tick agar lewat 1 siklus penuh.
        for i in 0 to 24 loop
            tick <= '1';
            wait for CLK_PERIOD;
            tick <= '0';
            wait for CLK_PERIOD*3;
        end loop;

        assert false
            report "Selesai. Urutan led yang benar: " &
                   "001(NS_HIJAU,x5)->010(NS_KUNING,x3)->100&100(ALL_RED_1,x1)->" &
                   "100(EW_HIJAU di bit5:3,x5)->010<<3(EW_KUNING,x3)->100&100(ALL_RED_2,x1)->ulang."
            severity note;
        wait;
    end process;

end sim;