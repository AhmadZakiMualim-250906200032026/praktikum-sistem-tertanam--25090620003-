----------------------------------------------------------------------------------
-- Jobsheet 7 - Mesin Status (FSM) II: Pengendali Lampu Lalu Lintas
-- Modul: traffic_light_fsm  (VERSI + TUGAS PRAKTIKUM 1 & 2)
-- Gaya rancangan: 2-process style (process sekuensial + process kombinasional)
--   - Process 1 (sekuensial) : register state_reg & timer_reg, maju saat tick='1'
--   - Process 2 (kombinasional): logika next-state & next-timer (timer menghitung turun)
--
-- State (6 fase, dengan ALL-RED sebagai jeda keselamatan -> Tugas Praktikum 1):
--   NS_HIJAU -> NS_KUNING -> ALL_RED_1 -> EW_HIJAU -> EW_KUNING -> ALL_RED_2 -> (kembali ke NS_HIJAU)
--
-- Durasi fase hijau diatur oleh switch sw(3 downto 0) -> Tugas Praktikum 2:
--   durasi_hijau = 5 + to_integer(unsigned(sw))   -- range 5..20 detik
--   Nilai switch dibaca ulang setiap kali FSM MEMASUKI state hijau (NS_HIJAU/EW_HIJAU),
--   supaya perubahan switch di tengah fase lain tidak mengubah hitungan yang sedang berjalan.
--
-- Output : led(2 downto 0) = arah Utara-Selatan  (bit0=hijau, bit1=kuning, bit2=merah)
--          led(5 downto 3) = arah Timur-Barat    (bit0=hijau, bit1=kuning, bit2=merah)
--          Pada ALL_RED_1/ALL_RED_2, kedua arah merah (bit2 NS dan bit2 EW = '1').
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity traffic_light_fsm is
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;                       -- dari tick_1hz, 1 pulsa/detik
           sw   : in  STD_LOGIC_VECTOR(3 downto 0);     -- atur durasi hijau: 5-20 detik
           led  : out STD_LOGIC_VECTOR(5 downto 0) );   -- led(2:0)=NS, led(5:3)=EW
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is

    type state_type is (NS_HIJAU, NS_KUNING, ALL_RED_1, EW_HIJAU, EW_KUNING, ALL_RED_2);

    -- Durasi fase tetap (dalam detik)
    constant KUNING_DUR   : integer := 3;   -- detik
    constant ALL_RED_DUR  : integer := 1;   -- detik, jeda keselamatan (Tugas 1)
    constant HIJAU_MIN    : integer := 5;   -- detik, batas bawah durasi hijau (Tugas 2)
    constant HIJAU_MAX    : integer := 20;  -- detik, batas atas durasi hijau (Tugas 2)

    signal state_reg, state_next : state_type := NS_HIJAU;
    signal timer_reg,  timer_next : integer range 0 to HIJAU_MAX-1 := HIJAU_MIN-1;

    -- durasi hijau saat ini, dibaca dari switch (0-15 -> 5-20 detik)
    signal hijau_dur : integer range HIJAU_MIN to HIJAU_MAX;

begin

    hijau_dur <= HIJAU_MIN + to_integer(unsigned(sw));

    ----------------------------------------------------------------
    -- Process 1 (sekuensial): register state dan timer
    -- Hanya "maju" ke state_next/timer_next saat tick='1' (1x per detik)
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_reg <= NS_HIJAU;
                timer_reg <= HIJAU_MIN - 1;
            elsif tick = '1' then
                state_reg <= state_next;
                timer_reg <= timer_next;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Process 2 (kombinasional): next-state & next-timer
    -- Timer dihitung turun tiap detik; saat timer = 0 -> pindah state
    -- dan timer diisi ulang sesuai durasi fase berikutnya.
    -- Durasi hijau diambil dari hijau_dur (switch) tepat saat MASUK
    -- ke NS_HIJAU / EW_HIJAU.
    ----------------------------------------------------------------
    process(state_reg, timer_reg, hijau_dur)
    begin
        -- default: tetap di state yang sama, timer turun 1
        state_next <= state_reg;
        timer_next <= timer_reg;

        if timer_reg = 0 then
            case state_reg is
                when NS_HIJAU =>
                    state_next <= NS_KUNING;
                    timer_next <= KUNING_DUR - 1;
                when NS_KUNING =>
                    state_next <= ALL_RED_1;
                    timer_next <= ALL_RED_DUR - 1;
                when ALL_RED_1 =>
                    state_next <= EW_HIJAU;
                    timer_next <= hijau_dur - 1;        -- baca switch saat masuk hijau
                when EW_HIJAU =>
                    state_next <= EW_KUNING;
                    timer_next <= KUNING_DUR - 1;
                when EW_KUNING =>
                    state_next <= ALL_RED_2;
                    timer_next <= ALL_RED_DUR - 1;
                when ALL_RED_2 =>
                    state_next <= NS_HIJAU;
                    timer_next <= hijau_dur - 1;        -- baca switch saat masuk hijau
            end case;
        else
            timer_next <= timer_reg - 1;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Decode output: state -> pola 6-bit LED
    -- Saling eksklusif per arah; NS/EW tidak pernah sama-sama hijau;
    -- pada ALL_RED_1/ALL_RED_2 kedua arah merah bersamaan.
    ----------------------------------------------------------------
    process(state_reg)
    begin
        case state_reg is
            when NS_HIJAU =>                    -- NS hijau, EW merah
                led <= "100" & "001";
            when NS_KUNING =>                    -- NS kuning, EW tetap merah
                led <= "100" & "010";
            when ALL_RED_1 =>                    -- kedua arah merah (jeda sebelum EW jalan)
                led <= "100" & "100";
            when EW_HIJAU =>                     -- EW hijau, NS merah
                led <= "001" & "100";
            when EW_KUNING =>                    -- EW kuning, NS tetap merah
                led <= "010" & "100";
            when ALL_RED_2 =>                    -- kedua arah merah (jeda sebelum NS jalan)
                led <= "100" & "100";
        end case;
    end process;

end Behavioral;