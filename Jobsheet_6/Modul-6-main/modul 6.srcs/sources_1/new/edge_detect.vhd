-- Langkah 4b: pulsa 1 clock saat tombol (debounced) naik 0->1.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detect is
    Port ( clk   : in  STD_LOGIC;
           din   : in  STD_LOGIC;
           pulse : out STD_LOGIC );
end edge_detect;

architecture Behavioral of edge_detect is
    signal prev : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            prev <= din;
        end if;
    end process;
    pulse <= din and not prev;
end Behavioral;