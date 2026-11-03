library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_top is
    Port ( clk : in  STD_LOGIC;
           sw  : in  STD_LOGIC_VECTOR (11 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           dp  : out STD_LOGIC;
           an  : out STD_LOGIC_VECTOR (3 downto 0) );
end temp_top;

architecture rtl of temp_top is
    signal digits : STD_LOGIC_VECTOR(15 downto 0);
    signal temp   : STD_LOGIC_VECTOR(15 downto 0);
begin
    conv: entity work.temp_conv
        port map (sw => sw, temp_q8_8 => temp, digits => digits);

    disp: entity work.seven_seg_driver
        generic map (DIGITS => 4)
        port map (clk  => clk,
                  data => digits,
                  dots => "0100",
                  seg  => seg, dp => dp, an => an);
end rtl;
