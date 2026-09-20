library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu4 is
end tb_alu4;

architecture sim of tb_alu4 is
    signal a, b   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal opcode : STD_LOGIC := '0';
    signal result : STD_LOGIC_VECTOR(3 downto 0);
    signal carry  : STD_LOGIC;
begin
    UUT : entity work.alu4
        port map ( a => a, b => b, opcode => opcode,
                   result => result, carry => carry );

    stim : process
    begin
        -- 1) 7 + 1 = 8  (contoh dari jobsheet)
        a <= "0111"; b <= "0001"; opcode <= '0'; wait for 10 ns;
        assert (result = "1000" and carry = '0')
            report "GAGAL: 7+1 harus result=1000 carry=0" severity error;

        -- 2) 15 + 1 = 16 -> result wrap jadi 0, carry = '1'
        a <= "1111"; b <= "0001"; opcode <= '0'; wait for 10 ns;
        assert (result = "0000" and carry = '1')
            report "GAGAL: 15+1 harus result=0000 carry=1" severity error;

        -- 3) 6 + 6 = 12
        a <= "0110"; b <= "0110"; opcode <= '0'; wait for 10 ns;
        assert (result = "1100" and carry = '0')
            report "GAGAL: 6+6 harus result=1100" severity error;

        -- 4) 8 - 1 = 7
        a <= "1000"; b <= "0001"; opcode <= '1'; wait for 10 ns;
        assert (result = "0111" and carry = '0')
            report "GAGAL: 8-1 harus result=0111 carry=0" severity error;

        -- 5) 1 - 2 = -1 (wrap jadi 1111), carry='1' artinya borrow
        a <= "0001"; b <= "0010"; opcode <= '1'; wait for 10 ns;
        assert (result = "1111" and carry = '1')
            report "GAGAL: 1-2 harus result=1111 carry=1" severity error;

        -- 6) 0 - 15 = -15 (wrap jadi 0001), carry='1'
        a <= "0000"; b <= "1111"; opcode <= '1'; wait for 10 ns;
        assert (result = "0001" and carry = '1')
            report "GAGAL: 0-15 harus result=0001 carry=1" severity error;

        report "Simulasi alu4 selesai.";
        wait;
    end process;
end sim;