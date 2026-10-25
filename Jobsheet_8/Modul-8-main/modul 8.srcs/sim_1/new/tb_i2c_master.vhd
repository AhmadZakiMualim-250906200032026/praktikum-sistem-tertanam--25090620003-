library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_i2c_master is
end tb_i2c_master;

architecture sim of tb_i2c_master is

    component i2c_master is
        generic ( CLK_FREQ : integer := 100_000_000;
                  SCL_FREQ : integer := 100_000 );
        Port ( clk        : in    STD_LOGIC;
               rst        : in    STD_LOGIC;
               start      : in    STD_LOGIC;
               rw         : in    STD_LOGIC;
               slave_addr : in    STD_LOGIC_VECTOR(6 downto 0);
               data_wr    : in    STD_LOGIC_VECTOR(7 downto 0);
               data_rd    : out   STD_LOGIC_VECTOR(7 downto 0);
               busy       : out   STD_LOGIC;
               done       : out   STD_LOGIC;
               ack_error  : out   STD_LOGIC;
               scl        : inout STD_LOGIC;
               sda        : inout STD_LOGIC );
    end component;

    constant CLK_PERIOD   : time := 10 ns;                           -- 100 MHz
    constant SLAVE_ADDR_C : STD_LOGIC_VECTOR(6 downto 0) := "1001000"; -- 0x48
    constant SLAVE_DATA_C : STD_LOGIC_VECTOR(7 downto 0) := x"A5";   -- data yang dikirim slave saat READ

    signal clk        : STD_LOGIC := '0';
    signal rst        : STD_LOGIC := '1';
    signal start      : STD_LOGIC := '0';
    signal rw         : STD_LOGIC := '0';
    signal slave_addr : STD_LOGIC_VECTOR(6 downto 0) := SLAVE_ADDR_C;
    signal data_wr    : STD_LOGIC_VECTOR(7 downto 0) := x"5A";
    signal data_rd    : STD_LOGIC_VECTOR(7 downto 0);
    signal busy, done, ack_error : STD_LOGIC;

    -- bus open-drain + pull-up eksternal (seperti resistor pull-up di Pmod)
    signal scl, sda  : STD_LOGIC;
    signal sda_slave : STD_LOGIC := 'Z';   -- driver SDA milik model slave

begin

    -- pull-up pasif ('H' = weak high)
    scl <= 'H';
    sda <= 'H';
    sda <= sda_slave;

    uut: i2c_master
        generic map ( CLK_FREQ => 100_000_000, SCL_FREQ => 100_000 )
        port map ( clk => clk, rst => rst, start => start, rw => rw,
                   slave_addr => slave_addr, data_wr => data_wr,
                   data_rd => data_rd, busy => busy, done => done,
                   ack_error => ack_error, scl => scl, sda => sda );

    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    ---------------------------------------------------------------------
    -- Model slave sederhana (open-drain): alamat 0x48
    --   WRITE : ACK alamat, terima 1 byte, ACK data
    --   READ  : ACK alamat, kirim SLAVE_DATA_C, lalu lepas SDA
    --   alamat lain : tidak menjawab (NACK)
    ---------------------------------------------------------------------
    slave_proc : process
        variable addr_rw : STD_LOGIC_VECTOR(7 downto 0);
        variable rx      : STD_LOGIC_VECTOR(7 downto 0);
    begin
        sda_slave <= 'Z';

        -- tunggu kondisi START: SDA turun saat SCL tinggi
        wait until falling_edge(sda) and to_x01(scl) = '1';

        -- terima 8 bit alamat + R/W (sample saat SCL naik)
        for i in 7 downto 0 loop
            wait until rising_edge(scl);
            addr_rw(i) := to_x01(sda);
        end loop;
        wait until falling_edge(scl);

        if addr_rw(7 downto 1) = SLAVE_ADDR_C then
            wait for 3 us;                      -- tunggu master melepas SDA
            sda_slave <= '0';                   -- ACK alamat
            wait until falling_edge(scl);       -- akhir slot ACK

            if addr_rw(0) = '0' then
                -- ===== WRITE: terima 1 byte =====
                sda_slave <= 'Z';
                for i in 7 downto 0 loop
                    wait until rising_edge(scl);
                    rx(i) := to_x01(sda);
                end loop;
                wait until falling_edge(scl);
                wait for 3 us;
                sda_slave <= '0';               -- ACK data
                wait until falling_edge(scl);
                sda_slave <= 'Z';
                report "Slave menerima data = " & integer'image(to_integer(unsigned(rx)));
            else
                -- ===== READ: kirim SLAVE_DATA_C, MSB dulu =====
                for i in 7 downto 0 loop
                    if SLAVE_DATA_C(i) = '0' then
                        sda_slave <= '0';
                    else
                        sda_slave <= 'Z';
                    end if;
                    wait until falling_edge(scl);
                end loop;
                sda_slave <= 'Z';
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------
    stim_proc : process
    begin
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        -- 1) WRITE ke slave 0x48
        rw    <= '0';
        start <= '1';
        wait until busy = '1';
        start <= '0';
        wait until done = '1';
        assert ack_error = '0' report "FAIL: transaksi WRITE mendapat NACK" severity error;
        report "Transaksi WRITE selesai, ack_error = " & STD_LOGIC'image(ack_error);
        wait for 20 us;

        -- 2) READ dari slave 0x48
        rw    <= '1';
        start <= '1';
        wait until busy = '1';
        start <= '0';
        wait until done = '1';
        assert ack_error = '0'     report "FAIL: transaksi READ mendapat NACK" severity error;
        assert data_rd = SLAVE_DATA_C report "FAIL: data_rd tidak sama dengan data slave" severity error;
        report "Transaksi READ selesai, data_rd = " & integer'image(to_integer(unsigned(data_rd)))
               & ", ack_error = " & STD_LOGIC'image(ack_error);
        wait for 20 us;

        -- 3) Alamat salah -> harus terdeteksi NACK
        slave_addr <= "0000001";
        rw         <= '0';
        start      <= '1';
        wait until busy = '1';
        start      <= '0';
        wait until done = '1';
        assert ack_error = '1' report "FAIL: NACK seharusnya terdeteksi" severity error;
        report "Alamat salah: ack_error = " & STD_LOGIC'image(ack_error) & " (NACK terdeteksi, sesuai harapan)";
        wait for 20 us;

        report "SIMULASI SELESAI";
        wait;
    end process;

end sim;