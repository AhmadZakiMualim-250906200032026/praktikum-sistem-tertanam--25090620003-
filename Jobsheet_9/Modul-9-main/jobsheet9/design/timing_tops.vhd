library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ===== Versi kombinasional =====
entity top_comb is
    Port ( clk : in STD_LOGIC;
           a, b : in STD_LOGIC_VECTOR(15 downto 0);
           result : out STD_LOGIC_VECTOR(15 downto 0) );
end top_comb;
architecture rtl of top_comb is
    signal a_r, b_r, r_c, r_r : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    process(clk) begin
        if rising_edge(clk) then
            a_r <= a; b_r <= b; r_r <= r_c;
        end if;
    end process;
    u: entity work.fixed_mul_q8_8 port map (a => a_r, b => b_r, result => r_c);
    result <= r_r;
end rtl;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ===== Versi pipeline 2 tahap =====
entity top_pipe2 is
    Port ( clk : in STD_LOGIC;
           a, b : in STD_LOGIC_VECTOR(15 downto 0);
           result : out STD_LOGIC_VECTOR(15 downto 0) );
end top_pipe2;
architecture rtl of top_pipe2 is
    signal a_r, b_r, r_c, r_r : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    process(clk) begin
        if rising_edge(clk) then
            a_r <= a; b_r <= b; r_r <= r_c;
        end if;
    end process;
    u: entity work.fixed_mul_pipe2 port map (clk => clk, a => a_r, b => b_r, result => r_c);
    result <= r_r;
end rtl;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ===== Versi pipeline 3 tahap =====
entity top_pipe3 is
    Port ( clk : in STD_LOGIC;
           a, b : in STD_LOGIC_VECTOR(15 downto 0);
           result : out STD_LOGIC_VECTOR(15 downto 0) );
end top_pipe3;
architecture rtl of top_pipe3 is
    signal a_r, b_r, r_c, r_r : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    process(clk) begin
        if rising_edge(clk) then
            a_r <= a; b_r <= b; r_r <= r_c;
        end if;
    end process;
    u: entity work.fixed_mul_pipe3 port map (clk => clk, a => a_r, b => b_r, result => r_c);
    result <= r_r;
end rtl;
