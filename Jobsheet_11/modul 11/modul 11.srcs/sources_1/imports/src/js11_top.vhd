----------------------------------------------------------------------------------
-- js11_top.vhd - top-level Jobsheet 11, Basys 3 (Prosedur + Tugas 1, 2, 3)
-- sw(3 downto 0) : posisi horizontal kotak merah (Tugas 2)
-- sw(4)          : pola  (0 = batang warna, 1 = papan catur / Tugas 1)
-- sw(5)          : mode  (0 = 640x480@60Hz 25 MHz, 1 = 800x600@60Hz 40 MHz / Tugas 3)
--
-- Pixel clock dibangkitkan langsung oleh MMCME2_BASE dari clock 100 MHz:
--   VCO = 100 MHz x 8 = 800 MHz ; clk25 = 800/32 ; clk40 = 800/20
-- lalu dipilih oleh BUFGMUX (pemilih clock bebas glitch).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity js11_top is
    Port ( clk      : in  STD_LOGIC;                      -- 100 MHz onboard
           sw       : in  STD_LOGIC_VECTOR(5 downto 0);
           Hsync    : out STD_LOGIC;
           Vsync    : out STD_LOGIC;
           vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
           vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0) );
end js11_top;

architecture Behavioral of js11_top is

    signal clkfb, clkfb_buf : std_logic;
    signal clk25, clk40     : std_logic;
    signal pclk             : std_logic;
    signal locked, rst      : std_logic;
    signal mode             : std_logic;

    signal video_on : std_logic;
    signal h_count  : integer range 0 to 1055;
    signal v_count  : integer range 0 to 627;
    signal rgb_bar, rgb_chk, rgb_pat, rgb_mix, rgb_out : std_logic_vector(11 downto 0);
    signal box_on   : std_logic;

begin
    mode <= sw(5);

    -- pembangkit clock 25 MHz dan 40 MHz
    u_mmcm : MMCME2_BASE
        generic map (
            BANDWIDTH          => "OPTIMIZED",
            CLKIN1_PERIOD      => 10.000,
            DIVCLK_DIVIDE      => 1,
            CLKFBOUT_MULT_F    => 8.000,
            CLKFBOUT_PHASE     => 0.000,
            CLKOUT0_DIVIDE_F   => 32.000,
            CLKOUT0_DUTY_CYCLE => 0.500,
            CLKOUT0_PHASE      => 0.000,
            CLKOUT1_DIVIDE     => 20,
            CLKOUT1_DUTY_CYCLE => 0.500,
            CLKOUT1_PHASE      => 0.000,
            REF_JITTER1        => 0.010,
            STARTUP_WAIT       => FALSE )
        port map (
            CLKOUT0   => clk25,
            CLKOUT0B  => open,
            CLKOUT1   => clk40,
            CLKOUT1B  => open,
            CLKOUT2   => open,
            CLKOUT2B  => open,
            CLKOUT3   => open,
            CLKOUT3B  => open,
            CLKOUT4   => open,
            CLKOUT5   => open,
            CLKOUT6   => open,
            CLKFBOUT  => clkfb,
            CLKFBOUTB => open,
            LOCKED    => locked,
            CLKIN1    => clk,
            PWRDWN    => '0',
            RST       => '0',
            CLKFBIN   => clkfb_buf );

    u_fb : BUFG port map ( I => clkfb, O => clkfb_buf );

    u_mux : BUFGMUX
        port map ( O => pclk, I0 => clk25, I1 => clk40, S => mode );

    rst <= not locked;   -- tahan reset sampai MMCM terkunci

    u_sync : entity work.vga_sync_multi
        port map ( pclk => pclk, rst => rst, mode => mode,
                   hsync => Hsync, vsync => Vsync, video_on => video_on,
                   h_count => h_count, v_count => v_count );

    u_bar : entity work.color_bar_pattern
        port map ( h_count => h_count, mode => mode, rgb => rgb_bar );

    u_chk : entity work.checkerboard_pattern
        port map ( h_count => h_count, v_count => v_count, rgb => rgb_chk );

    u_box : entity work.box_indicator
        port map ( h_count => h_count, v_count => v_count,
                   sw => sw(3 downto 0), mode => mode, box_on => box_on );

    rgb_pat <= rgb_chk when sw(4) = '1' else rgb_bar;
    rgb_mix <= x"F00"  when box_on = '1' else rgb_pat;   -- kotak merah
    rgb_out <= rgb_mix when video_on = '1' else x"000";  -- hitam di luar area aktif

    vgaRed   <= rgb_out(11 downto 8);
    vgaGreen <= rgb_out(7 downto 4);
    vgaBlue  <= rgb_out(3 downto 0);
end Behavioral;
