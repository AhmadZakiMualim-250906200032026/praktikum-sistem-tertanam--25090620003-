----------------------------------------------------------------------------------
-- tb_vga_sync.vhd (Prosedur no. 2)
-- Simulasi sedikit lebih dari 2 frame (~35,6 ms waktu simulasi). Assert memeriksa:
--   * lebar pulsa Hsync = 96 piksel, periode Hsync = 800 piksel
--   * lebar pulsa Vsync = 2 baris (2 x 800 piksel), periode Vsync = 525 baris
--   * video_on = '1' hanya bila h_count < 640 dan v_count < 480
-- Jalankan Behavioral Simulation, lalu ketik di Tcl Console: run all
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_vga_sync is
end tb_vga_sync;

architecture sim of tb_vga_sync is
    constant T_PCLK  : time := 40 ns;           -- 25 MHz
    constant T_LINE  : time := 800 * T_PCLK;    -- 32 us
    constant T_FRAME : time := 525 * T_LINE;    -- 16,8 ms

    signal pclk     : std_logic := '0';
    signal rst      : std_logic := '1';
    signal hsync    : std_logic;
    signal vsync    : std_logic;
    signal video_on : std_logic;
    signal h_count  : integer range 0 to 799;
    signal v_count  : integer range 0 to 524;
    signal done     : boolean := false;
    signal n_h      : integer := 0;   -- jumlah pulsa hsync lengkap
    signal n_v      : integer := 0;   -- jumlah pulsa vsync lengkap
begin

    dut : entity work.vga_sync
        port map ( pclk => pclk, rst => rst, hsync => hsync, vsync => vsync,
                   video_on => video_on, h_count => h_count, v_count => v_count );

    -- pixel clock 25 MHz
    clk_gen : process
    begin
        while not done loop
            pclk <= '0'; wait for T_PCLK/2;
            pclk <= '1'; wait for T_PCLK/2;
        end loop;
        wait;
    end process;

    -- monitor Hsync
    mon_h : process
        variable t_fall, t_prev : time := 0 ns;
        variable have_prev : boolean := false;
    begin
        wait until falling_edge(hsync);
        t_fall := now;
        if have_prev then
            assert (t_fall - t_prev) = T_LINE
                report "Periode Hsync salah: " & time'image(t_fall - t_prev)
                severity error;
        end if;
        t_prev := t_fall; have_prev := true;
        wait until rising_edge(hsync);
        assert (now - t_fall) = 96 * T_PCLK
            report "Lebar pulsa Hsync salah: " & time'image(now - t_fall)
            severity error;
        n_h <= n_h + 1;
    end process;

    -- monitor Vsync
    mon_v : process
        variable t_fall, t_prev : time := 0 ns;
        variable have_prev : boolean := false;
    begin
        wait until falling_edge(vsync);
        t_fall := now;
        if have_prev then
            assert (t_fall - t_prev) = T_FRAME
                report "Periode Vsync salah: " & time'image(t_fall - t_prev)
                severity error;
        end if;
        t_prev := t_fall; have_prev := true;
        wait until rising_edge(vsync);
        assert (now - t_fall) = 2 * T_LINE
            report "Lebar pulsa Vsync salah: " & time'image(now - t_fall)
            severity error;
        n_v <= n_v + 1;
    end process;

    -- cek video_on
    chk_von : process
    begin
        wait until falling_edge(pclk);
        assert (video_on = '1') = ((h_count < 640) and (v_count < 480))
            report "video_on tidak sesuai area aktif" severity error;
    end process;

    -- stimulus
    stim : process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 2 * T_FRAME + 2 ms;     -- sedikit lebih dari 2 frame
        assert n_h > 1000
            report "Jumlah pulsa Hsync kurang: " & integer'image(n_h) severity error;
        assert n_v = 2
            report "Jumlah pulsa Vsync bukan 2: " & integer'image(n_v) severity error;
        report "SELESAI. Pulsa Hsync=" & integer'image(n_h) &
               ", pulsa Vsync=" & integer'image(n_v) &
               ". Bila tidak ada pesan Error di atas, pewaktuan sesuai Tabel 11.1."
               severity note;
        done <= true;
        wait;
    end process;

end sim;
