library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js03_tugas3 is
    Port ( sw  : in  STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0) );
end js03_tugas3;

architecture Behavioral of js03_tugas3 is
    signal result   : STD_LOGIC_VECTOR(3 downto 0);
    signal overflow : STD_LOGIC;
begin
    UUT : entity work.alu4s
        port map ( a        => sw(3 downto 0),
                   b        => sw(7 downto 4),
                   opcode   => sw(15),
                   result   => result,
                   overflow => overflow );

    led(3 downto 0)  <= result;
    led(4)           <= overflow;
    led(15 downto 5) <= (others => '0');
end Behavioral;