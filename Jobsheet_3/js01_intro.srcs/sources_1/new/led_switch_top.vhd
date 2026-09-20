library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_switch_top is
    Port ( sw  : in  STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0) );
end led_switch_top;

architecture Behavioral of led_switch_top is
begin
    -- Hanya led[7:0] aktif, kebalikan dari sw[7:0]
    led(7 downto 0)  <= not sw(7 downto 0);
    -- led[15:8] dipadamkan
    led(15 downto 8) <= (others => '0');
end Behavioral;