----------------------------------------------------------------------------------
-- checkerboard_pattern.vhd (Tugas Praktikum no. 1) - versi 2
-- Papan catur dari XOR bit h_count dan v_count (bit 5 => kotak 32x32 piksel).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity checkerboard_pattern is
    Port ( h_count : in  integer range 0 to 1055;
           v_count : in  integer range 0 to 627;
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end checkerboard_pattern;

architecture Behavioral of checkerboard_pattern is
    signal h_vec : unsigned(10 downto 0);
    signal v_vec : unsigned(10 downto 0);
    signal chk   : std_logic;
begin
    h_vec <= to_unsigned(h_count, 11);
    v_vec <= to_unsigned(v_count, 11);
    chk   <= h_vec(5) xor v_vec(5);

    rgb <= x"FFF" when chk = '1' else x"000";  -- putih / hitam
end Behavioral;
