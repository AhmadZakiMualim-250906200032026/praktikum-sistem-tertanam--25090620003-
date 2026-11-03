library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Perkalian Q2.2 x Q2.2 (unsigned, 4 bit) -> Q4.4 (8 bit)
-- Q2.2 : 2 bit bulat, 2 bit pecahan, rentang 0 - 3,75, resolusi 0,25
-- Q4.4 : 4 bit bulat, 4 bit pecahan, rentang 0 - 15,94, resolusi 0,0625
entity fixed_mul_q2_2 is
    Port ( a      : in  STD_LOGIC_VECTOR (3 downto 0);
           b      : in  STD_LOGIC_VECTOR (3 downto 0);
           result : out STD_LOGIC_VECTOR (7 downto 0) );
end fixed_mul_q2_2;

architecture Behavioral of fixed_mul_q2_2 is
begin
    result <= STD_LOGIC_VECTOR(unsigned(a) * unsigned(b));
end Behavioral;