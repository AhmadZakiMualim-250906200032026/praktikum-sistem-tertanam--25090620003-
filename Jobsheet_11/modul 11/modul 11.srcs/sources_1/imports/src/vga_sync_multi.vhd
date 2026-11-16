----------------------------------------------------------------------------------
-- vga_sync_multi.vhd (Tugas Praktikum no. 3)
-- Sync generator dua mode, dipilih oleh 'mode':
--   mode = '0' : 640x480@60Hz   (pixel clock 25 MHz,  sync aktif RENDAH)
--   mode = '1' : 800x600@60Hz   (pixel clock 40 MHz,  sync aktif TINGGI)
-- Pixel clock (pclk) dipilih di luar modul ini (BUFGMUX di js11_top).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_sync_multi is
    Port ( pclk     : in  STD_LOGIC;
           rst      : in  STD_LOGIC;
           mode     : in  STD_LOGIC;
           hsync    : out STD_LOGIC;
           vsync    : out STD_LOGIC;
           video_on : out STD_LOGIC;
           h_count  : out integer range 0 to 1055;
           v_count  : out integer range 0 to 627 );
end vga_sync_multi;

architecture Behavioral of vga_sync_multi is
    signal m1, m2 : std_logic := '0';          -- sinkronisasi 'mode' ke pclk
    signal hc, vc : integer range 0 to 2047 := 0;

    signal h_disp, h_fp, h_sync, h_tot : integer range 0 to 1056;
    signal v_disp, v_fp, v_sync, v_tot : integer range 0 to 628;
    signal h_pulse, v_pulse : boolean;
    signal hs_n, vs_n       : std_logic;       -- sync aktif rendah
begin
    -- sinkronisasi 2 flip-flop untuk sinyal switch
    process(pclk)
    begin
        if rising_edge(pclk) then
            m1 <= mode;
            m2 <= m1;
        end if;
    end process;

    -- parameter pewaktuan sesuai mode
    h_disp <= 800  when m2 = '1' else 640;
    h_fp   <= 40   when m2 = '1' else 16;
    h_sync <= 128  when m2 = '1' else 96;
    h_tot  <= 1056 when m2 = '1' else 800;
    v_disp <= 600  when m2 = '1' else 480;
    v_fp   <= 1    when m2 = '1' else 10;
    v_sync <= 4    when m2 = '1' else 2;
    v_tot  <= 628  when m2 = '1' else 525;

    -- pencacah; pakai ">=" agar pulih sendiri saat mode berganti
    process(pclk)
    begin
        if rising_edge(pclk) then
            if rst = '1' then
                hc <= 0; vc <= 0;
            elsif hc >= h_tot-1 then
                hc <= 0;
                if vc >= v_tot-1 then vc <= 0; else vc <= vc + 1; end if;
            else
                hc <= hc + 1;
            end if;
        end if;
    end process;

    h_pulse <= (hc >= h_disp + h_fp) and (hc < h_disp + h_fp + h_sync);
    v_pulse <= (vc >= v_disp + v_fp) and (vc < v_disp + v_fp + v_sync);

    hs_n <= '0' when h_pulse else '1';
    vs_n <= '0' when v_pulse else '1';

    -- 640x480: aktif rendah; 800x600: aktif tinggi (dibalik)
    hsync <= not hs_n when m2 = '1' else hs_n;
    vsync <= not vs_n when m2 = '1' else vs_n;

    video_on <= '1' when (hc < h_disp) and (vc < v_disp) else '0';

    h_count <= hc when hc <= 1055 else 1055;
    v_count <= vc when vc <= 627  else 627;
end Behavioral;
