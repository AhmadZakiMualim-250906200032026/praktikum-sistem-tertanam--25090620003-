library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
    Generic ( CLK_FREQ_HZ : integer := 100_000_000;
              STABLE_MS   : integer := 10 );
    Port ( clk     : in  STD_LOGIC;
           btn_in  : in  STD_LOGIC;   -- sinyal mentah dari tombol
           btn_out : out STD_LOGIC ); -- sinyal bersih (debounced)
end debounce;

architecture Behavioral of debounce is
    constant LIMIT : integer := (CLK_FREQ_HZ / 1000) * STABLE_MS;
    signal ff1, ff2, ff3 : STD_LOGIC := '0';  -- ff1-ff2: synchronizer, ff3: sampel sebelumnya
    signal cnt    : integer range 0 to LIMIT := 0;
    signal stable : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            ff1 <= btn_in;
            ff2 <= ff1;
            ff3 <= ff2;
            if ff2 /= ff3 then
                cnt <= 0;               -- input berubah -> hitung ulang
            elsif cnt < LIMIT then
                cnt <= cnt + 1;
            else
                stable <= ff2;          -- stabil sepanjang LIMIT siklus
            end if;
        end if;
    end process;
    btn_out <= stable;
end Behavioral;