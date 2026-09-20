library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity leading_one_detector is
    Generic ( WIDTH : integer := 8 );
    Port ( din   : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           pos   : out STD_LOGIC_VECTOR (2 downto 0);   -- posisi bit '1' (0..7)
           valid : out STD_LOGIC );                      -- '1' jika ada bit '1'
end leading_one_detector;

architecture Behavioral of leading_one_detector is
begin
    process(din)
    begin
        pos   <= (others => '0');
        valid <= '0';
        for i in WIDTH-1 downto 0 loop        -- scan dari kiri (indeks 7) ke kanan (0)
            if din(i) = '1' then
                pos   <= STD_LOGIC_VECTOR(to_unsigned(i, 3));
                valid <= '1';
                exit;                          -- ketemu yang pertama (paling kiri), berhenti
            end if;
        end loop;
    end process;
end Behavioral;