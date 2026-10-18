----------------------------------------------------------------------------------
-- Jobsheet 7 - Testbench sederhana untuk tick_1hz
-- CLK_FREQ_HZ diperkecil menjadi 10 (bukan 100_000_000) agar simulasi cepat:
-- tick seharusnya muncul setiap 10 siklus clk.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tick_1hz_tb is
end tick_1hz_tb;

architecture sim of tick_1hz_tb is

    constant CLK_PERIOD : time := 10 ns;
    constant TEST_FREQ  : integer := 10;  -- diperkecil dari 100_000_000 untuk simulasi

    signal clk  : STD_LOGIC := '0';
    signal rst  : STD_LOGIC := '0';
    signal tick : STD_LOGIC;

begin

    DUT : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => TEST_FREQ )
        port map ( clk => clk, rst => rst, tick => tick );

    -- Pembangkit clock
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Stimulus & pemeriksaan periode tick
    stim_process : process
    begin
        rst <= '1';
        wait for CLK_PERIOD*2;
        rst <= '0';

        -- Biarkan berjalan beberapa periode TEST_FREQ siklus,
        -- amati sinyal 'tick' pada waveform: harus '1' setiap TEST_FREQ siklus clk.
        wait for CLK_PERIOD * TEST_FREQ * 3;

        assert false report "Simulasi selesai - periksa waveform: tick muncul tiap 10 siklus clk" severity note;
        wait;
    end process;

end sim;