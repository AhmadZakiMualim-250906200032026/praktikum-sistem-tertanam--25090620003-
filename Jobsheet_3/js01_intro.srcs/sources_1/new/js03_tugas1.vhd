library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js03_tugas1 is
    Port ( sw  : in  STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0) );
end js03_tugas1;

architecture Behavioral of js03_tugas1 is
    signal result    : STD_LOGIC_VECTOR(3 downto 0);
    signal result_hi : STD_LOGIC_VECTOR(3 downto 0);
    signal carry     : STD_LOGIC;
begin
    UUT : entity work.alu4x
        port map ( a         => sw(3 downto 0),   -- operand a
                   b         => sw(7 downto 4),   -- operand b
                   opcode    => sw(9 downto 8),   -- 00=+, 01=-, 10=x
                   result    => result,
                   result_hi => result_hi,
                   carry     => carry );

    led(3 downto 0)  <= result;
    led(4)           <= carry;
    led(8 downto 5)  <= result_hi;
    led(15 downto 9) <= (others => '0');
end Behavioral;