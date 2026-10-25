library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bram_256x8 is
end tb_bram_256x8;

architecture sim of tb_bram_256x8 is

    component bram_256x8 is
        Port ( clk  : in  STD_LOGIC;
               we   : in  STD_LOGIC;
               addr : in  STD_LOGIC_VECTOR (7 downto 0);
               din  : in  STD_LOGIC_VECTOR (7 downto 0);
               dout : out STD_LOGIC_VECTOR (7 downto 0) );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal we   : STD_LOGIC := '0';
    signal addr : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal din  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal dout : STD_LOGIC_VECTOR(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: bram_256x8
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
        we <= '1';

        addr <= x"00"; din <= x"AA"; wait until rising_edge(clk); wait for 1 ns;
        addr <= x"01"; din <= x"BB"; wait until rising_edge(clk); wait for 1 ns;
        addr <= x"7F"; din <= x"CC"; wait until rising_edge(clk); wait for 1 ns;

        we <= '0';

        -- baca kembali alamat 0x00 -> harus 0xAA (ingat: output registered, perlu 1 clock extra delay)
        addr <= x"00"; wait until rising_edge(clk); wait for 1 ns;
        wait until rising_edge(clk); wait for 1 ns;
        assert dout = x"AA" report "FAIL: alamat 0x00 seharusnya 0xAA" severity error;

        -- baca kembali alamat 0x01 -> harus 0xBB
        addr <= x"01"; wait until rising_edge(clk); wait for 1 ns;
        wait until rising_edge(clk); wait for 1 ns;
        assert dout = x"BB" report "FAIL: alamat 0x01 seharusnya 0xBB" severity error;

        -- baca kembali alamat 0x7F -> harus 0xCC
        addr <= x"7F"; wait until rising_edge(clk); wait for 1 ns;
        wait until rising_edge(clk); wait for 1 ns;
        assert dout = x"CC" report "FAIL: alamat 0x7F seharusnya 0xCC" severity error;

        report "SEMUA TEST BRAM BERHASIL (jika tidak ada FAIL di atas)";
        wait;
    end process;

end sim;