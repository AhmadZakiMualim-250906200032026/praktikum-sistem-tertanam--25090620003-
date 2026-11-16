----------------------------------------------------------------------------------
-- color_bar_pattern.vhd (Prosedur no. 3) - versi 2 (dua resolusi)
-- 8 batang warna vertikal: zona 80 px (640 lebar) atau 100 px (800 lebar)
-- rgb(11 downto 8)=Merah, (7 downto 4)=Hijau, (3 downto 0)=Biru
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity color_bar_pattern is
    Port ( h_count : in  integer range 0 to 1055;
           mode    : in  STD_LOGIC;     -- '0' = 640x480, '1' = 800x600
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end color_bar_pattern;

architecture Behavioral of color_bar_pattern is
    signal zone : integer range 0 to 13;
begin
    zone <= h_count / 100 when mode = '1' else h_count / 80;

    process(zone)
    begin
        case zone is
            when 0      => rgb <= x"FFF";  -- putih
            when 1      => rgb <= x"FF0";  -- kuning
            when 2      => rgb <= x"0FF";  -- cyan
            when 3      => rgb <= x"0F0";  -- hijau
            when 4      => rgb <= x"F0F";  -- magenta
            when 5      => rgb <= x"F00";  -- merah
            when 6      => rgb <= x"00F";  -- biru
            when others => rgb <= x"000";  -- hitam
        end case;
    end process;
end Behavioral;
