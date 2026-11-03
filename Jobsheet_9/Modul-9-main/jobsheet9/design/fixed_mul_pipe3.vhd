library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_mul_pipe3 is
    Port ( clk    : in  STD_LOGIC;
           a      : in  STD_LOGIC_VECTOR (15 downto 0);
           b      : in  STD_LOGIC_VECTOR (15 downto 0);
           result : out STD_LOGIC_VECTOR (15 downto 0) );
end fixed_mul_pipe3;

architecture Behavioral of fixed_mul_pipe3 is
    signal p_lo, p_hi  : unsigned(23 downto 0);          -- tahap 1: perkalian parsial
    signal sum_reg     : unsigned(31 downto 0);          -- tahap 2: penjumlahan
    signal result_reg  : STD_LOGIC_VECTOR(15 downto 0);  -- tahap 3: scaling
begin
    process(clk)
    begin
        if rising_edge(clk) then
            p_lo       <= unsigned(a) * unsigned(b(7 downto 0));
            p_hi       <= unsigned(a) * unsigned(b(15 downto 8));
            sum_reg    <= shift_left(resize(p_hi, 32), 8) + resize(p_lo, 32);
            result_reg <= STD_LOGIC_VECTOR(sum_reg(23 downto 8));
        end if;
    end process;
    result <= result_reg;
end Behavioral;
