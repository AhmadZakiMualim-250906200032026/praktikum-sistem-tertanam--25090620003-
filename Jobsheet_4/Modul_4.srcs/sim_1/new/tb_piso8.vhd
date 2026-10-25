library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_piso8 is
end tb_piso8;

architecture sim of tb_piso8 is
    signal clk  : STD_LOGIC := '0';
    signal load : STD_LOGIC := '1';
    signal d    : STD_LOGIC_VECTOR(7 downto 0) := "10110011";
    signal sout : STD_LOGIC;
begin
    UUT : entity work.piso8
        port map ( clk => clk, load => load, d => d, sout => sout );

    clk <= not clk after 10 ns;   -- periode 20 ns

    stim : process
    begin
        wait for 5 ns;
        wait until rising_edge(clk);   -- tepi muat: reg <= 10110011
        load <= '0';
        wait for 1 ns;

        -- kirim 8 bit MSB dulu: 1,0,1,1,0,0,1,1
        for i in 7 downto 0 loop
            assert sout = d(i)
                report "GAGAL: urutan sout salah pada bit " &
                       integer'image(i) severity error;
            wait until rising_edge(clk);   -- tepi geser
            wait for 1 ns;
        end loop;

        report "Simulasi PISO selesai.";
        wait;
    end process;
end sim;