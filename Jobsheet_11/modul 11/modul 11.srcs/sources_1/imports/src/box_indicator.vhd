----------------------------------------------------------------------------------
-- box_indicator.vhd (Tugas Praktikum no. 2) - versi 2 (dua resolusi)
-- 640x480 : kotak 40x40,  X = sw*40, Y = 220
-- 800x600 : kotak 50x50,  X = sw*50, Y = 275
-- Kotak selalu persis muat di area aktif saat sw = 0 .. 15.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity box_indicator is
    Port ( h_count : in  integer range 0 to 1055;
           v_count : in  integer range 0 to 627;
           sw      : in  STD_LOGIC_VECTOR(3 downto 0);
           mode    : in  STD_LOGIC;
           box_on  : out STD_LOGIC );
end box_indicator;

architecture Behavioral of box_indicator is
    signal box_size : integer range 0 to 64;
    signal box_x    : integer range 0 to 800;
    signal box_y    : integer range 0 to 600;
begin
    box_size <= 50  when mode = '1' else 40;
    box_y    <= 275 when mode = '1' else 220;
    box_x    <= to_integer(unsigned(sw)) * 50 when mode = '1'
                else to_integer(unsigned(sw)) * 40;

    box_on <= '1' when (h_count >= box_x) and (h_count < box_x + box_size) and
                       (v_count >= box_y) and (v_count < box_y + box_size)
              else '0';
end Behavioral;
