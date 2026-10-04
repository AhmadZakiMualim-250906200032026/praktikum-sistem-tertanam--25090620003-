library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port ( clk  : in  STD_LOGIC;
           btnU : in  STD_LOGIC;
           btnD : in  STD_LOGIC;
           btnC : in  STD_LOGIC;
           sw   : in  STD_LOGIC;    -- sw(0) di papan: freeze
           seg  : out STD_LOGIC_VECTOR(6 downto 0);
           dp   : out STD_LOGIC;
           an   : out STD_LOGIC_VECTOR(3 downto 0) );
end js05_top;

architecture Behavioral of js05_top is
    -- Tugas 3: ubah angka ini (10 normal; coba 1, 2, 5, 10)
    constant DEB_MS : integer := 10;

    signal up_deb, down_deb, clear_deb : STD_LOGIC;
    signal up_pulse, down_pulse        : STD_LOGIC;
    signal up_eff, down_eff            : STD_LOGIC;
    signal cnt_val                     : STD_LOGIC_VECTOR(15 downto 0);
begin
    DBU : entity work.debounce
        generic map ( STABLE_MS => DEB_MS )
        port map ( clk => clk, btn_in => btnU, btn_out => up_deb );
    DBD : entity work.debounce
        generic map ( STABLE_MS => DEB_MS )
        port map ( clk => clk, btn_in => btnD, btn_out => down_deb );
    DBC : entity work.debounce
        generic map ( STABLE_MS => DEB_MS )
        port map ( clk => clk, btn_in => btnC, btn_out => clear_deb );

    EDU : entity work.edge_detect
        port map ( clk => clk, sig_in => up_deb, pulse => up_pulse );
    EDD : entity work.edge_detect
        port map ( clk => clk, sig_in => down_deb, pulse => down_pulse );

    -- Tugas 2: sw = '1' -> pulsa naik/turun diblokir
    up_eff   <= up_pulse   and not sw;
    down_eff <= down_pulse and not sw;

    CNT1 : entity work.updown_counter
        port map ( clk => clk, up => up_eff, down => down_eff,
                   clear => clear_deb, count => cnt_val );

    DRV : entity work.seven_seg_driver
        port map ( clk => clk, value => cnt_val, seg => seg, dp => dp, an => an );
end Behavioral;