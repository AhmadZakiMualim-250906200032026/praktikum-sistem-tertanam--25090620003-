library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master is
    generic (
        CLK_FREQ : integer := 100_000_000;  -- clock sistem 100 MHz
        SCL_FREQ : integer := 100_000       -- target SCL 100 kHz (standard mode)
    );
    Port (
        clk        : in    STD_LOGIC;
        rst        : in    STD_LOGIC;
        start      : in    STD_LOGIC;                      -- tahan '1' sampai busy = '1'
        rw         : in    STD_LOGIC;                      -- '0'=write, '1'=read
        slave_addr : in    STD_LOGIC_VECTOR(6 downto 0);
        data_wr    : in    STD_LOGIC_VECTOR(7 downto 0);
        data_rd    : out   STD_LOGIC_VECTOR(7 downto 0);
        busy       : out   STD_LOGIC;
        done       : out   STD_LOGIC;
        ack_error  : out   STD_LOGIC;
        scl        : inout STD_LOGIC;
        sda        : inout STD_LOGIC
    );
end i2c_master;

architecture Behavioral of i2c_master is

    -- clk_en muncul 4 kali per periode SCL (1 kali per fase)
    constant DIVIDER : integer := CLK_FREQ / (SCL_FREQ * 4);

    type i2c_state is (S_IDLE, S_START, S_ADDR, S_ADDR_ACK,
                       S_WDATA, S_WDATA_ACK,
                       S_RDATA, S_RDATA_ACK,
                       S_STOP);
    signal state : i2c_state := S_IDLE;

    -- 4 fase per bit:
    --   fase 0: SCL rendah, SDA diset
    --   fase 1: SCL naik
    --   fase 2: SCL tinggi (SDA stabil, titik sampling)
    --   fase 3: SCL turun
    signal phase : integer range 0 to 3 := 0;

    signal clk_cnt : integer range 0 to DIVIDER-1 := 0;
    signal clk_en  : STD_LOGIC := '0';

    signal bit_cnt     : integer range 0 to 7 := 7;
    signal shift_addr  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal shift_data  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal data_rd_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    signal sda_out   : STD_LOGIC := '1';
    signal sda_en    : STD_LOGIC := '0';  -- '1' = master drive SDA, '0' = dilepas (Z)
    signal scl_drive : STD_LOGIC := '1';  -- '1' = SCL dilepas (tinggi), '0' = ditarik rendah

    signal rw_reg      : STD_LOGIC := '0';
    signal ack_error_i : STD_LOGIC := '0';

begin

    -- ===== Clock divider -> clk_en setiap 1/4 periode SCL =====
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                clk_cnt <= 0;
                clk_en  <= '0';
            elsif clk_cnt = DIVIDER-1 then
                clk_cnt <= 0;
                clk_en  <= '1';
            else
                clk_cnt <= clk_cnt + 1;
                clk_en  <= '0';
            end if;
        end if;
    end process;

    -- ===== FSM utama (mengikuti Kode 8.2, ditambah S_WDATA/S_RDATA terpisah) =====
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state       <= S_IDLE;
                phase       <= 0;
                busy        <= '0';
                done        <= '0';
                data_rd     <= (others => '0');
                ack_error   <= '0';
                ack_error_i <= '0';
                sda_en      <= '0';
                sda_out     <= '1';
                scl_drive   <= '1';
            elsif clk_en = '1' then
                done <= '0';

                case state is

                    ---------------------------------------------------------
                    when S_IDLE =>
                        scl_drive <= '1';
                        sda_en    <= '0';
                        busy      <= '0';
                        phase     <= 0;
                        if start = '1' then
                            busy        <= '1';
                            rw_reg      <= rw;
                            shift_addr  <= slave_addr & rw;   -- 7-bit alamat + bit R/W
                            bit_cnt     <= 7;
                            ack_error_i <= '0';
                            state       <= S_START;
                        end if;

                    ---------------------------------------------------------
                    when S_START =>      -- SDA turun saat SCL tinggi
                        case phase is
                            when 0 =>
                                sda_en  <= '1';
                                sda_out <= '0';
                                phase   <= 1;
                            when 1 =>
                                phase <= 2;
                            when 2 =>
                                scl_drive <= '0';
                                phase     <= 3;
                            when others =>
                                phase <= 0;
                                state <= S_ADDR;
                        end case;

                    ---------------------------------------------------------
                    when S_ADDR =>       -- kirim 8 bit (7 alamat + R/W), MSB dulu
                        case phase is
                            when 0 =>
                                sda_en  <= '1';
                                sda_out <= shift_addr(bit_cnt);
                                phase   <= 1;
                            when 1 =>
                                scl_drive <= '1';
                                phase     <= 2;
                            when 2 =>
                                phase <= 3;
                            when others =>
                                scl_drive <= '0';
                                phase     <= 0;
                                if bit_cnt = 0 then
                                    state <= S_ADDR_ACK;
                                else
                                    bit_cnt <= bit_cnt - 1;
                                end if;
                        end case;

                    ---------------------------------------------------------
                    when S_ADDR_ACK =>   -- lepas SDA, slave menarik SDA ke '0' = ACK
                        case phase is
                            when 0 =>
                                sda_en <= '0';
                                phase  <= 1;
                            when 1 =>
                                scl_drive <= '1';
                                phase     <= 2;
                            when 2 =>
                                if to_x01(sda) = '1' then    -- 'H' dan '1' sama-sama dianggap tinggi
                                    ack_error_i <= '1';       -- NACK
                                end if;
                                phase <= 3;
                            when others =>
                                scl_drive <= '0';
                                phase     <= 0;
                                bit_cnt   <= 7;
                                if ack_error_i = '1' then
                                    state <= S_STOP;          -- alamat tidak dijawab, akhiri transaksi
                                elsif rw_reg = '0' then
                                    shift_data <= data_wr;
                                    state      <= S_WDATA;
                                else
                                    state <= S_RDATA;
                                end if;
                        end case;

                    ---------------------------------------------------------
                    when S_WDATA =>      -- kirim 1 byte data
                        case phase is
                            when 0 =>
                                sda_en  <= '1';
                                sda_out <= shift_data(bit_cnt);
                                phase   <= 1;
                            when 1 =>
                                scl_drive <= '1';
                                phase     <= 2;
                            when 2 =>
                                phase <= 3;
                            when others =>
                                scl_drive <= '0';
                                phase     <= 0;
                                if bit_cnt = 0 then
                                    state <= S_WDATA_ACK;
                                else
                                    bit_cnt <= bit_cnt - 1;
                                end if;
                        end case;

                    ---------------------------------------------------------
                    when S_WDATA_ACK =>
                        case phase is
                            when 0 =>
                                sda_en <= '0';
                                phase  <= 1;
                            when 1 =>
                                scl_drive <= '1';
                                phase     <= 2;
                            when 2 =>
                                if to_x01(sda) = '1' then
                                    ack_error_i <= '1';
                                end if;
                                phase <= 3;
                            when others =>
                                scl_drive <= '0';
                                phase     <= 0;
                                state     <= S_STOP;
                        end case;

                    ---------------------------------------------------------
                    when S_RDATA =>      -- terima 1 byte, slave yang drive SDA
                        case phase is
                            when 0 =>
                                sda_en <= '0';
                                phase  <= 1;
                            when 1 =>
                                scl_drive <= '1';
                                phase     <= 2;
                            when 2 =>
                                data_rd_reg(bit_cnt) <= to_x01(sda);
                                phase <= 3;
                            when others =>
                                scl_drive <= '0';
                                phase     <= 0;
                                if bit_cnt = 0 then
                                    state <= S_RDATA_ACK;
                                else
                                    bit_cnt <= bit_cnt - 1;
                                end if;
                        end case;

                    ---------------------------------------------------------
                    when S_RDATA_ACK =>  -- master kirim NACK (akhir pembacaan 1 byte)
                        case phase is
                            when 0 =>
                                sda_en  <= '1';
                                sda_out <= '1';
                                phase   <= 1;
                            when 1 =>
                                scl_drive <= '1';
                                phase     <= 2;
                            when 2 =>
                                phase <= 3;
                            when others =>
                                scl_drive <= '0';
                                phase     <= 0;
                                state     <= S_STOP;
                        end case;

                    ---------------------------------------------------------
                    when S_STOP =>       -- SDA naik saat SCL tinggi
                        case phase is
                            when 0 =>
                                sda_en  <= '1';
                                sda_out <= '0';       -- pastikan SDA rendah selagi SCL rendah
                                phase   <= 1;
                            when 1 =>
                                scl_drive <= '1';     -- SCL naik
                                phase     <= 2;
                            when 2 =>
                                sda_out <= '1';       -- SDA naik saat SCL tinggi = STOP
                                phase   <= 3;
                            when others =>
                                phase     <= 0;
                                state     <= S_IDLE;
                                busy      <= '0';
                                done      <= '1';
                                data_rd   <= data_rd_reg;
                                ack_error <= ack_error_i;
                        end case;

                end case;
            end if;
        end if;
    end process;

    -- ===== Driver tri-state untuk open-drain SCL/SDA =====
    scl <= '0' when scl_drive = '0' else 'Z';
    sda <= sda_out when sda_en = '1' else 'Z';

end Behavioral;