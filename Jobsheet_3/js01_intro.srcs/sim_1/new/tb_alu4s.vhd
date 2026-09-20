library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu4s is
end tb_alu4s;

architecture sim of tb_alu4s is
    signal a, b     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal opcode   : STD_LOGIC := '0';
    signal result   : STD_LOGIC_VECTOR(3 downto 0);
    signal overflow : STD_LOGIC;
begin
    UUT : entity work.alu4s
        port map ( a => a, b => b, opcode => opcode,
                   result => result, overflow => overflow );

    stim : process
    begin
        -- 1) 7 + 1 = +8 -> OVERFLOW (di atas +7)
        a <= "0111"; b <= "0001"; opcode <= '0'; wait for 10 ns;
        assert (result = "1000" and overflow = '1')
            report "GAGAL: 7+1 harus 1000 ov=1" severity error;

        -- 2) -8 + -1 = -9 -> OVERFLOW (di bawah -8)
        a <= "1000"; b <= "1111"; opcode <= '0'; wait for 10 ns;
        assert (result = "0111" and overflow = '1')
            report "GAGAL: -8+-1 harus 0111 ov=1" severity error;

        -- 3) 3 + 1 = 4 -> normal
        a <= "0011"; b <= "0001"; opcode <= '0'; wait for 10 ns;
        assert (result = "0100" and overflow = '0')
            report "GAGAL: 3+1 harus 0100 ov=0" severity error;

        -- 4) -8 + 7 = -1 -> normal (operand berbeda tanda)
        a <= "1000"; b <= "0111"; opcode <= '0'; wait for 10 ns;
        assert (result = "1111" and overflow = '0')
            report "GAGAL: -8+7 harus 1111 ov=0" severity error;

        -- 5) 6 - (-6) = 12 -> OVERFLOW
        a <= "0110"; b <= "1010"; opcode <= '1'; wait for 10 ns;
        assert (result = "1100" and overflow = '1')
            report "GAGAL: 6-(-6) harus 1100 ov=1" severity error;

        -- 6) -4 - 4 = -8 -> pas di batas, TIDAK overflow
        a <= "1100"; b <= "0100"; opcode <= '1'; wait for 10 ns;
        assert (result = "1000" and overflow = '0')
            report "GAGAL: -4-4 harus 1000 ov=0" severity error;

        report "Simulasi alu4s selesai.";
        wait;
    end process;
end sim;