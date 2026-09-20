library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu4x is
end tb_alu4x;

architecture sim of tb_alu4x is
    signal a, b      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal opcode    : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal result    : STD_LOGIC_VECTOR(3 downto 0);
    signal result_hi : STD_LOGIC_VECTOR(3 downto 0);
    signal carry     : STD_LOGIC;
begin
    UUT : entity work.alu4x
        port map ( a => a, b => b, opcode => opcode,
                   result => result, result_hi => result_hi, carry => carry );

    stim : process
    begin
        -- 1) 7 + 1 = 8
        a <= "0111"; b <= "0001"; opcode <= "00"; wait for 10 ns;
        assert (result = "1000" and carry = '0')
            report "GAGAL: 7+1 harus 1000 carry=0" severity error;

        -- 2) 15 + 1 = 16 -> wrap 0000, carry=1
        a <= "1111"; b <= "0001"; opcode <= "00"; wait for 10 ns;
        assert (result = "0000" and carry = '1')
            report "GAGAL: 15+1 harus 0000 carry=1" severity error;

        -- 3) 8 - 1 = 7
        a <= "1000"; b <= "0001"; opcode <= "01"; wait for 10 ns;
        assert (result = "0111" and carry = '0')
            report "GAGAL: 8-1 harus 0111" severity error;

        -- 4) 1 - 2 = -1 (wrap 1111), carry=1
        a <= "0001"; b <= "0010"; opcode <= "01"; wait for 10 ns;
        assert (result = "1111" and carry = '1')
            report "GAGAL: 1-2 harus 1111 carry=1" severity error;

        -- 5) 7 x 7 = 49 = 0011_0001
        a <= "0111"; b <= "0111"; opcode <= "10"; wait for 10 ns;
        assert (result = "0001" and result_hi = "0011")
            report "GAGAL: 7x7 harus hi=0011 lo=0001" severity error;

        -- 6) 15 x 15 = 225 = 1110_0001
        a <= "1111"; b <= "1111"; opcode <= "10"; wait for 10 ns;
        assert (result = "0001" and result_hi = "1110")
            report "GAGAL: 15x15 harus hi=1110 lo=0001" severity error;

        -- 7) 2 x 3 = 6 = 0000_0110
        a <= "0010"; b <= "0011"; opcode <= "10"; wait for 10 ns;
        assert (result = "0110" and result_hi = "0000")
            report "GAGAL: 2x3 harus hi=0000 lo=0110" severity error;

        -- 8) 0 x 9 = 0
        a <= "0000"; b <= "1001"; opcode <= "10"; wait for 10 ns;
        assert (result = "0000" and result_hi = "0000")
            report "GAGAL: 0x9 harus 0" severity error;

        report "Simulasi alu4x selesai.";
        wait;
    end process;
end sim;