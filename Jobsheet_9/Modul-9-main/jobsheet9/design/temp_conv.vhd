library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temp_conv is
    Port ( sw        : in  STD_LOGIC_VECTOR (11 downto 0);   -- kode ADC 12-bit tiruan
           temp_q8_8 : out STD_LOGIC_VECTOR (15 downto 0);   -- suhu format Q8.8
           digits    : out STD_LOGIC_VECTOR (15 downto 0) ); -- [puluhan][satuan][desimal][C]
end temp_conv;

architecture rtl of temp_conv is
    -- 100/4095 dalam Q0.16 = 0.0244 x 65536 ~ 1600
    constant K : unsigned(10 downto 0) := to_unsigned(1600, 11);

    signal prod  : unsigned(22 downto 0);
    signal t_q   : unsigned(15 downto 0);
    signal t_int : integer range 0 to 255;
    signal tens, ones, tenth : integer range 0 to 9;
begin
    prod <= unsigned(sw) * K;
    t_q  <= "0" & prod(22 downto 8);

    t_int <= to_integer(t_q(15 downto 8));
    tens  <= t_int / 10;
    ones  <= t_int mod 10;
    tenth <= (to_integer(t_q(7 downto 0)) * 10) / 256;

    temp_q8_8 <= std_logic_vector(t_q);
    digits    <= std_logic_vector(to_unsigned(tens, 4)) &
                 std_logic_vector(to_unsigned(ones, 4)) &
                 std_logic_vector(to_unsigned(tenth, 4)) &
                 x"C";
end rtl;
