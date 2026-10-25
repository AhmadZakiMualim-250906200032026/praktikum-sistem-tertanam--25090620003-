library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js04_sync_top is
    Port ( clk  : in  STD_LOGIC;
           btnC : in  STD_LOGIC;
           led  : out STD_LOGIC_VECTOR(15 downto 0) );
end js04_sync_top;

architecture Behavioral of js04_sync_top is
    signal sync_out : STD_LOGIC;
    signal prev     : STD_LOGIC := '0';
    signal toggle   : STD_LOGIC := '0';
begin
    SYNC1 : entity work.synchronizer_2ff
        port map ( clk => clk, async_in => btnC, sync_out => sync_out );

    -- deteksi transisi '0'->'1' lalu toggle
    process(clk)
    begin
        if rising_edge(clk) then
            if sync_out = '1' and prev = '0' then
                toggle <= not toggle;
            end if;
            prev <= sync_out;
        end if;
    end process;

    led(0)           <= toggle;
    led(15 downto 1) <= (others => '0');
end Behavioral;