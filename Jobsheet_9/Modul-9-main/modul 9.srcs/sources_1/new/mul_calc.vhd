library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- sw[7:4] = A (Q2.2), sw[3:0] = B (Q2.2)
-- Hasil Q4.4 dikonversi ke 4 digit: [puluhan][satuan][desimal1][desimal2]
-- Contoh: 3,75 x 3,75 = 14,0625 -> tampil 14.06
entity mul_calc is
    Port ( sw        : in  STD_LOGIC_VECTOR (7 downto 0);
           prod_q4_4 : out STD_LOGIC_VECTOR (7 downto 0);
           digits    : out STD_LOGIC_VECTOR (15 downto 0) );
end mul_calc;

architecture rtl of mul_calc is
    signal p      : STD_LOGIC_VECTOR(7 downto 0);
    signal i_int  : integer range 0 to 15;
    signal f_dec  : integer range 0 to 99;   -- pecahan dalam persen (0..93)
    signal tens, ones, ft, fo : integer range 0 to 9;
begin
    mul: entity work.fixed_mul_q2_2
        port map (a => sw(7 downto 4), b => sw(3 downto 0), result => p);

    i_int <= to_integer(unsigned(p(7 downto 4)));
    f_dec <= (to_integer(unsigned(p(3 downto 0))) * 25) / 4;   -- x/16 -> persen

    tens <= i_int / 10;
    ones <= i_int mod 10;
    ft   <= f_dec / 10;
    fo   <= f_dec mod 10;

    prod_q4_4 <= p;
    digits <= STD_LOGIC_VECTOR(to_unsigned(tens, 4)) &
              STD_LOGIC_VECTOR(to_unsigned(ones, 4)) &
              STD_LOGIC_VECTOR(to_unsigned(ft, 4)) &
              STD_LOGIC_VECTOR(to_unsigned(fo, 4));
end rtl;