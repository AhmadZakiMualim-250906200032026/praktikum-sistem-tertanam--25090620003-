-- Langkah 5: driver seven-segment 4 digit, multiplexing, aktif-LOW (Basys 3).
-- Versi desimal: nibble 0-9 = angka, A = tanda minus, B = huruf 'r', E = huruf 'E', F = kosong.
-- seg(6 downto 0) = g f e d c b a
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Port ( clk  : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR(15 downto 0);
           seg  : out STD_LOGIC_VECTOR(6 downto 0);
           an   : out STD_LOGIC_VECTOR(3 downto 0);
           dp   : out STD_LOGIC );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    signal cnt : unsigned(17 downto 0) := (others => '0');
    signal sel : STD_LOGIC_VECTOR(1 downto 0);
    signal nib : STD_LOGIC_VECTOR(3 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            cnt <= cnt + 1;
        end if;
    end process;
    sel <= std_logic_vector(cnt(17 downto 16));

    with sel select an <=
        "1110" when "00",
        "1101" when "01",
        "1011" when "10",
        "0111" when others;

    with sel select nib <=
        data(3 downto 0)   when "00",
        data(7 downto 4)   when "01",
        data(11 downto 8)  when "10",
        data(15 downto 12) when others;

    with nib select seg <=
        "1000000" when x"0",
        "1111001" when x"1",
        "0100100" when x"2",
        "0110000" when x"3",
        "0011001" when x"4",
        "0010010" when x"5",
        "0000010" when x"6",
        "1111000" when x"7",
        "0000000" when x"8",
        "0010000" when x"9",
        "0111111" when x"A",   -- minus (segmen g saja)
        "0101111" when x"B",   -- huruf r (segmen e, g)
        "1000110" when x"C",
        "0100001" when x"D",
        "0000110" when x"E",
        "1111111" when others; -- F = kosong

    dp <= '1';  -- titik mati
end Behavioral;