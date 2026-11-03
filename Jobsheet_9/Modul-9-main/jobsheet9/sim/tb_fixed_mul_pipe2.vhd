library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_fixed_mul_pipe2 is
end tb_fixed_mul_pipe2;

architecture sim of tb_fixed_mul_pipe2 is
    constant LAT : integer := 2;   -- latency pipeline (siklus clock)
    constant N   : integer := 6;
    type vec_t is array (0 to N-1) of std_logic_vector(15 downto 0);
    constant A_V : vec_t := (x"0200", x"0180", x"0080", x"0A00", x"0100", x"0000");
    constant B_V : vec_t := (x"0300", x"0180", x"0080", x"0C80", x"0100", x"0500");
    constant E_V : vec_t := (x"0600", x"0240", x"0040", x"7D00", x"0100", x"0000");

    signal clk : std_logic := '0';
    signal a, b, result : std_logic_vector(15 downto 0) := (others => '0');
begin
    clk <= not clk after 5 ns;   -- 100 MHz

    uut: entity work.fixed_mul_pipe2
        port map (clk => clk, a => a, b => b, result => result);

    process
        variable k : integer;
    begin
        for i in 0 to N + LAT - 2 loop
            if i < N then
                a <= A_V(i); b <= B_V(i);
            else
                a <= (others => '0'); b <= (others => '0');
            end if;
            wait until rising_edge(clk);
            wait for 1 ns;
            k := i - (LAT - 1);
            if k >= 0 and k < N then
                assert result = E_V(k)
                    report "GAGAL pada vektor ke-" & integer'image(k)
                    severity error;
            end if;
        end loop;
        report "Simulasi pipe2 selesai" severity note;
        wait;
    end process;
end sim;
