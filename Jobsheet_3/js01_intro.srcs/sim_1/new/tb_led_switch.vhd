library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_led_switch is
end tb_led_switch;

architecture Behavioral of tb_led_switch is
    signal sw  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal led : STD_LOGIC_VECTOR(15 downto 0);
begin
    uut: entity work.led_switch_top port map (sw => sw, led => led);

    stim: process
    begin
        sw <= (others => '0');      wait for 100 ns;
        sw <= "0000000011111111";   wait for 100 ns;
        sw <= "0000000010100101";   wait for 100 ns;
        sw <= "1111111100000000";   wait for 100 ns;
        wait;
    end process;
end Behavioral;