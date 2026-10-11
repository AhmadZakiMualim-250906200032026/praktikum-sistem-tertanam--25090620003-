-- Langkah 4-5: top level. btnL = reset, btnU = muat A, btnD = muat B, btnC = hitung/enter.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity calculator_top is
    Generic ( DB_CNT : integer := 1_000_000 );
    Port ( clk : in  STD_LOGIC;
           sw  : in  STD_LOGIC_VECTOR(15 downto 0);
           btnC, btnU, btnL, btnD : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR(15 downto 0);
           seg : out STD_LOGIC_VECTOR(6 downto 0);
           an  : out STD_LOGIC_VECTOR(3 downto 0);
           dp  : out STD_LOGIC );
end calculator_top;

architecture Behavioral of calculator_top is
    signal db_c, db_u, db_d, rst : STD_LOGIC;
    signal p_c, p_u, p_d         : STD_LOGIC;
    signal disp   : STD_LOGIC_VECTOR(15 downto 0);
    signal flag   : STD_LOGIC;
    signal st_led : STD_LOGIC_VECTOR(3 downto 0);
    signal op_s   : STD_LOGIC_VECTOR(1 downto 0);
    signal show_s : STD_LOGIC;
    signal dec    : STD_LOGIC_VECTOR(15 downto 0);
    signal ovf_s  : STD_LOGIC;
begin
    DB_C_I : entity work.debounce generic map (CNT_MAX => DB_CNT) port map (clk, btnC, db_c);
    DB_U_I : entity work.debounce generic map (CNT_MAX => DB_CNT) port map (clk, btnU, db_u);
    DB_D_I : entity work.debounce generic map (CNT_MAX => DB_CNT) port map (clk, btnD, db_d);
    DB_L_I : entity work.debounce generic map (CNT_MAX => DB_CNT) port map (clk, btnL, rst);

    ED_C : entity work.edge_detect port map (clk, db_c, p_c);
    ED_U : entity work.edge_detect port map (clk, db_u, p_u);
    ED_D : entity work.edge_detect port map (clk, db_d, p_d);

    FSM : entity work.calculator_fsm
        port map (clk => clk, rst => rst, sw => sw,
                  pu => p_u, pd => p_d, pc => p_c,
                  disp => disp, flag => flag, state_led => st_led,
                  op_out => op_s, show => show_s);

    -- biner -> desimal (BCD) + format tampilan; sw(13) = tampilkan sisa (bagi) / digit puluh-ribuan (kali)
    DEC_I : entity work.disp_dec
        port map (clk => clk, show => show_s, op => op_s, flag => flag,
                  res => disp, sw8 => sw(7 downto 0), sel_rem => sw(13), ovf => ovf_s, data => dec);

    SSD : entity work.seven_seg_driver
        port map (clk => clk, data => dec, seg => seg, an => an, dp => dp);

    led(3 downto 0)  <= st_led;
    led(14 downto 4) <= (others => '0');
    led(15)          <= flag or ovf_s;   -- borrow / bagi-nol / hasil kali > 9999
end Behavioral;