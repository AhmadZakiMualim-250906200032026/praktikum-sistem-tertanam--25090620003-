library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js04_piso_top is
    Port ( sw   : in  STD_LOGIC_VECTOR(15 downto 0);
           clk  : in  STD_LOGIC;
           btnC : in  STD_LOGIC;
           led  : out STD_LOGIC_VECTOR(15 downto 0) );
end js04_piso_top;

architecture Behavioral of js04_piso_top is
begin
    UUT : entity work.piso8
        port map ( clk => clk, load => btnC, d => sw(7 downto 0), sout => led(0) );

    led(15 downto 1) <= (others => '0');
end Behavioral;