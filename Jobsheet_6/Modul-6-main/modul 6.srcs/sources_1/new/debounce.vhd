-- Langkah 4a: debounce. Output berubah hanya jika input stabil CNT_MAX clock.
-- 100 MHz, CNT_MAX=1_000_000 -> ~10 ms.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
    Generic ( CNT_MAX : integer := 1_000_000 );
    Port ( clk  : in  STD_LOGIC;
           din  : in  STD_LOGIC;
           dout : out STD_LOGIC );
end debounce;

architecture Behavioral of debounce is
    signal s0, s1, stable : STD_LOGIC := '0';
    signal cnt : integer range 0 to CNT_MAX := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            s0 <= din;      -- sinkronisasi 2 flip-flop
            s1 <= s0;
            if s1 /= stable then
                if cnt = CNT_MAX then
                    stable <= s1;
                    cnt    <= 0;
                else
                    cnt <= cnt + 1;
                end if;
            else
                cnt <= 0;
            end if;
        end if;
    end process;
    dout <= stable;
end Behavioral;