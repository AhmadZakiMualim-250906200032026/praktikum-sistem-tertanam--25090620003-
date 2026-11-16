----------------------------------------------------------------------------------
-- tb_vga_sync_multi.vhd - verifikasi mode 800x600@60Hz (mode = '1', pclk 40 MHz)
--   * pulsa Hsync TINGGI selama 128 piksel (3,2 us), periode 1056 piksel (26,4 us)
--   * pulsa Vsync TINGGI selama 4 baris (105,6 us), periode 628 baris (16,5792 ms)
--   * video_on = '1' hanya bila h_count < 800 dan v_count < 600
-- Jalankan Behavioral Simulation, lalu di Tcl Console: run all
-- (mode 640x480 sudah diuji oleh tb_vga_sync.vhd)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_vga_sync_multi is
end tb_vga_sync_multi;

architecture sim of tb_vga_sync_multi is
    constant T_PCLK  : time := 25 ns;            -- 40 MHz
    constant T_LINE  : time := 1056 * T_PCLK;    -- 26,4 us
    constant T_FRAME : time := 628 * T_LINE;     -- 16,5792 ms

    signal pclk     : std_logic := '0';
    signal rst      : std_logic := '1';
    signal mode     : std_logic := '1';
    signal hsync    : std_logic;
    signal vsync    : std_logic;
    signal video_on : std_logic;
    signal h_count  : integer range 0 to 1055;
    signal v_count  : integer range 0 to 627;
    signal done     : boolean := false;
    signal n_h      : integer := 0;
    signal n_v      : integer := 0;
begin

    dut : entity work.vga_sync_multi
        port map ( pclk => pclk, rst => rst, mode => mode,
                   hsync => hsync, vsync => vsync, video_on => video_on,
                   h_count => h_count, v_count => v_count );

    clk_gen : process
    begin
        while not done loop
            pclk <= '0'; wait for T_PCLK/2;
            pclk <= '1'; wait for T_PCLK/2;
        end loop;
        wait;
    end process;

    mon_h : process
        variable t_rise, t_prev : time := 0 ns;
        variable have_prev : boolean := false;
    begin
        wait for 200 ns;                       -- lewati transisi awal (reset/sinkronisasi mode)
        loop
            wait until rising_edge(hsync);
            t_rise := now;
            if have_prev then
                assert (t_rise - t_prev) = T_LINE
                    report "Periode Hsync salah: " & time'image(t_rise - t_prev)
                    severity error;
            end if;
            t_prev := t_rise; have_prev := true;
            wait until falling_edge(hsync);
            assert (now - t_rise) = 128 * T_PCLK
                report "Lebar pulsa Hsync salah: " & time'image(now - t_rise)
                severity error;
            n_h <= n_h + 1;
        end loop;
    end process;

    mon_v : process
        variable t_rise, t_prev : time := 0 ns;
        variable have_prev : boolean := false;
    begin
        wait for 200 ns;
        loop
            wait until rising_edge(vsync);
            t_rise := now;
            if have_prev then
                assert (t_rise - t_prev) = T_FRAME
                    report "Periode Vsync salah: " & time'image(t_rise - t_prev)
                    severity error;
            end if;
            t_prev := t_rise; have_prev := true;
            wait until falling_edge(vsync);
            assert (now - t_rise) = 4 * T_LINE
                report "Lebar pulsa Vsync salah: " & time'image(now - t_rise)
                severity error;
            n_v <= n_v + 1;
        end loop;
    end process;

    chk_von : process
    begin
        wait for 200 ns;
        loop
            wait until falling_edge(pclk);
            assert (video_on = '1') = ((h_count < 800) and (v_count < 600))
                report "video_on tidak sesuai area aktif" severity error;
        end loop;
    end process;

    stim : process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 2 * T_FRAME + 2 ms;
        assert n_h > 1200
            report "Jumlah pulsa Hsync kurang: " & integer'image(n_h) severity error;
        assert n_v = 2
            report "Jumlah pulsa Vsync bukan 2: " & integer'image(n_v) severity error;
        report "SELESAI 800x600. Pulsa Hsync=" & integer'image(n_h) &
               ", pulsa Vsync=" & integer'image(n_v) &
               ". Bila tidak ada pesan Error di atas, pewaktuan sesuai." severity note;
        done <= true;
        wait;
    end process;

end sim;
