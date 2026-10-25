library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bram_1024x8 is
end tb_bram_1024x8;

architecture sim of tb_bram_1024x8 is

    component bram_1024x8 is
        Port ( clk  : in  STD_LOGIC;
               we   : in  STD_LOGIC;
               addr : in  STD_LOGIC_VECTOR (9 downto 0);
               din  : in  STD_LOGIC_VECTOR (7 downto 0);
               dout : out STD_LOGIC_VECTOR (7 downto 0) );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal we   : STD_LOGIC := '0';
    signal addr : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal din  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal dout : STD_LOGIC_VECTOR(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: bram_1024x8
        port map ( clk => clk, we => we, addr => addr, din => din, dout => dout );

    -- generate clock
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc : process
    begin
        -- tulis 3 data ke 3 alamat berbeda
        -- (0x000 dan 0x100 hanya beda di bit alamat atas -> menguji alamat 10 bit)
        we <= '1';

        addr <= "0000000000"; din <= x"AA"; wait until rising_edge(clk); wait for 1 ns;  -- 0x000
        addr <= "0100000000"; din <= x"BB"; wait until rising_edge(clk); wait for 1 ns;  -- 0x100
        addr <= "1111111111"; din <= x"CC"; wait until rising_edge(clk); wait for 1 ns;  -- 0x3FF

        we <= '0';

        -- baca kembali alamat 0x000 -> harus 0xAA (output registered, perlu 1 clock extra delay)
        addr <= "0000000000"; wait until rising_edge(clk); wait for 1 ns;
        wait until rising_edge(clk); wait for 1 ns;
        assert dout = x"AA" report "FAIL: alamat 0x000 seharusnya 0xAA" severity error;

        -- baca kembali alamat 0x100 -> harus 0xBB
        addr <= "0100000000"; wait until rising_edge(clk); wait for 1 ns;
        wait until rising_edge(clk); wait for 1 ns;
        assert dout = x"BB" report "FAIL: alamat 0x100 seharusnya 0xBB" severity error;

        -- baca kembali alamat 0x3FF -> harus 0xCC
        addr <= "1111111111"; wait until rising_edge(clk); wait for 1 ns;
        wait until rising_edge(clk); wait for 1 ns;
        assert dout = x"CC" report "FAIL: alamat 0x3FF seharusnya 0xCC" severity error;

        report "SEMUA TEST BRAM 1024x8 BERHASIL (jika tidak ada FAIL di atas)";
        wait;
    end process;

end sim;