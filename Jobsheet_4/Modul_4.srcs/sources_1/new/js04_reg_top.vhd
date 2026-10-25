library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js04_reg_top is
    Port ( sw   : in  STD_LOGIC_VECTOR(15 downto 0);
           clk  : in  STD_LOGIC;
           btnC : in  STD_LOGIC;
           btnU : in  STD_LOGIC;
           led  : out STD_LOGIC_VECTOR(15 downto 0) );
end js04_reg_top;

architecture Behavioral of js04_reg_top is
    signal q_int : STD_LOGIC_VECTOR(7 downto 0);
begin
    UUT : entity work.reg8_en
        port map ( clk => clk,
                   rst => btnU,              -- btnU = reset
                   en  => btnC,              -- btnC = enable (muat data)
                   d   => sw(7 downto 0),
                   q   => q_int );

    led(7 downto 0)  <= q_int;
    led(15 downto 8) <= (others => '0');
end Behavioral;