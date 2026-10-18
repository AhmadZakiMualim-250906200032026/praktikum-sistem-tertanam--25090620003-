----------------------------------------------------------------------------------
-- Jobsheet 7 - Mesin Status (FSM) II: Pengendali Lampu Lalu Lintas
-- Modul: top_traffic_light (top-level untuk Basys 3) - VERSI + TUGAS PRAKTIKUM 1 & 2
-- Menggabungkan tick_1hz (pembagi clock) dengan traffic_light_fsm.
-- Pinout yang dipakai di constraint (.xdc):
--   clk        -> clock onboard 100 MHz (W5)
--   btnC       -> tombol reset tengah (U18)
--   sw(3:0)    -> SW0-SW3, atur durasi hijau 5-20 detik (Tugas Praktikum 2)
--   led(5:0)   -> LD5..LD0 di papan Basys 3
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_traffic_light is
    Port ( clk  : in  STD_LOGIC;
           btnC : in  STD_LOGIC;                      -- reset (aktif tinggi)
           sw   : in  STD_LOGIC_VECTOR(3 downto 0);    -- atur durasi hijau
           led  : out STD_LOGIC_VECTOR(5 downto 0) );
end top_traffic_light;

architecture Structural of top_traffic_light is

    signal tick_sig : STD_LOGIC;

begin

    U_TICK : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => 100_000_000 )
        port map ( clk  => clk,
                   rst  => btnC,
                   tick => tick_sig );

    U_FSM : entity work.traffic_light_fsm
        port map ( clk  => clk,
                   rst  => btnC,
                   tick => tick_sig,
                   sw   => sw,
                   led  => led );

end Structural;