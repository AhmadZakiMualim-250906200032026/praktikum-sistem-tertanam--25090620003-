library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mul_top is
    Port ( clk : in  STD_LOGIC;
           sw  : in  STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           dp  : out STD_LOGIC;
           an  : out STD_LOGIC_VECTOR (3 downto 0) );
end mul_top;

architecture rtl of mul_top is
    signal digits : STD_LOGIC_VECTOR(15 downto 0);
    signal prod   : STD_LOGIC_VECTOR(7 downto 0);
begin
    calc: entity work.mul_calc
        port map (sw => sw, prod_q4_4 => prod, digits => digits);

    disp: entity work.seven_seg_driver
        generic map (DIGITS => 4)
        port map (clk  => clk,
                  data => digits,
                  dots => "0100",      -- titik desimal setelah digit satuan
                  seg  => seg, dp => dp, an => an);
end rtl;