-- Konversi biner -> desimal (BCD) + format tampilan untuk seven_seg_driver.
-- Kode nibble keluaran: 0-9 = angka, A = minus, B = 'r', E = 'E', F = kosong.
--
-- Isi tampilan:
--   show='0' (sedang input)   : nilai sw(7:0) dalam desimal
--   tambah  (op "00")         : 0..510
--   kurang  (op "01")         : a>=b -> hasil; a<b (flag=1) -> "-" + nilai mutlak (mis. -2)
--   bagi    (op "10")         : hasil bagi; sel_rem='1' -> sisa; b=0 (flag=1) -> "Err"
--   kali    (op "11")         : 0..65025. Display hanya 4 digit, jadi:
--                                 hasil <= 9999 : tampil biasa
--                                 hasil >  9999 : ovf='1'; sel_rem='0' -> 4 digit terakhir (nol di depan
--                                                 TIDAK dikosongkan), sel_rem='1' -> digit puluh-ribuan
--
-- Pipeline (semua register) supaya timing 100 MHz aman:
--   tahap 1: pilih nilai + hitung nilai mutlak
--   tahap 2-5: double-dabble 16 bit, masing-masing 4 iterasi (total 16)
--   tahap 6: hilangkan nol di depan + sisip tanda
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp_dec is
    Port ( clk     : in  STD_LOGIC;
           show    : in  STD_LOGIC;                       -- '1' = tampilkan hasil
           op      : in  STD_LOGIC_VECTOR(1 downto 0);    -- operasi yang dipilih
           flag    : in  STD_LOGIC;                       -- borrow / bagi-nol
           res     : in  STD_LOGIC_VECTOR(15 downto 0);   -- hasil dari FSM (bagi: sisa & hasil bagi)
           sw8     : in  STD_LOGIC_VECTOR(7 downto 0);    -- nilai input saat belum S_SHOW
           sel_rem : in  STD_LOGIC;                       -- bagi: tampil sisa; kali: tampil puluh-ribuan
           ovf     : out STD_LOGIC;                       -- '1' = hasil kali > 9999 (tidak muat 4 digit)
           data    : out STD_LOGIC_VECTOR(15 downto 0) ); -- 4 nibble ke seven_seg_driver
end disp_dec;

architecture Behavioral of disp_dec is
    constant C_MINUS : STD_LOGIC_VECTOR(3 downto 0) := x"A";
    constant C_R     : STD_LOGIC_VECTOR(3 downto 0) := x"B";
    constant C_E     : STD_LOGIC_VECTOR(3 downto 0) := x"E";
    constant C_BLANK : STD_LOGIC_VECTOR(3 downto 0) := x"F";

    subtype dab_t is unsigned(35 downto 0);   -- [d4 d3 d2 d1 d0 (35:16)][biner (15:0)]

    -- 4 iterasi double dabble
    function dabble4(zin : dab_t) return dab_t is
        variable z  : dab_t := zin;
        variable lo : integer;
    begin
        for i in 0 to 3 loop
            for n in 0 to 4 loop
                lo := 16 + 4*n;
                if z(lo+3 downto lo) > 4 then
                    z(lo+3 downto lo) := z(lo+3 downto lo) + 3;
                end if;
            end loop;
            z := z(34 downto 0) & '0';
        end loop;
        return z;
    end function;

    signal val1                 : unsigned(15 downto 0) := (others => '0');
    signal fl1, fl2, fl3, fl4, fl5 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); -- (neg, err, top, full)
    signal z2, z3, z4, z5       : dab_t := (others => '0');
    signal data_r               : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
begin
    process(clk)
        variable v    : unsigned(15 downto 0);
        variable neg, err, top, full : STD_LOGIC;
        variable z0   : dab_t;
        variable d4, d3, d2, d1, d0  : STD_LOGIC_VECTOR(3 downto 0);
        variable sgn  : STD_LOGIC_VECTOR(3 downto 0);
    begin
        if rising_edge(clk) then
            ----------------------------------------------------------------
            -- tahap 1: pilih nilai yang ditampilkan
            ----------------------------------------------------------------
            v := (others => '0');
            neg := '0'; err := '0'; top := '0'; full := '0';
            ovf <= '0';
            if show = '0' then
                v(7 downto 0) := unsigned(sw8);
            else
                case op is
                    when "01" =>                                    -- kurang
                        if flag = '1' then                          -- a < b : tampilkan -(b-a)
                            v(7 downto 0) := unsigned(not res(7 downto 0)) + 1;
                            neg := '1';
                        else
                            v(7 downto 0) := unsigned(res(7 downto 0));
                        end if;
                    when "10" =>                                    -- bagi
                        if flag = '1' then
                            err := '1';                             -- bagi nol
                        elsif sel_rem = '1' then
                            v(7 downto 0) := unsigned(res(15 downto 8));  -- sisa
                        else
                            v(7 downto 0) := unsigned(res(7 downto 0));   -- hasil bagi
                        end if;
                    when "11" =>                                    -- kali (0..65025)
                        v := unsigned(res);
                        if v > 9999 then
                            ovf <= '1';
                            if sel_rem = '0' then full := '1'; end if;
                        end if;
                        top := sel_rem;
                    when others =>                                  -- tambah (0..510)
                        v(8 downto 0) := unsigned(res(8 downto 0));
                end case;
            end if;
            val1 <= v;
            fl1  <= neg & err & top & full;

            ----------------------------------------------------------------
            -- tahap 2-5: double dabble 16 bit (4 x 4 iterasi)
            ----------------------------------------------------------------
            z0 := (others => '0');
            z0(15 downto 0) := val1;
            z2  <= dabble4(z0);   fl2 <= fl1;
            z3  <= dabble4(z2);   fl3 <= fl2;
            z4  <= dabble4(z3);   fl4 <= fl3;
            z5  <= dabble4(z4);   fl5 <= fl4;

            ----------------------------------------------------------------
            -- tahap 6: format 4 digit (nol di depan dikosongkan, minus tepat di kiri angka)
            ----------------------------------------------------------------
            d4 := std_logic_vector(z5(35 downto 32));
            d3 := std_logic_vector(z5(31 downto 28));
            d2 := std_logic_vector(z5(27 downto 24));
            d1 := std_logic_vector(z5(23 downto 20));
            d0 := std_logic_vector(z5(19 downto 16));
            if fl5(3) = '1' then sgn := C_MINUS; else sgn := C_BLANK; end if;

            if fl5(2) = '1' then                                    -- error (bagi nol): " Err"
                data_r <= C_BLANK & C_E & C_R & C_R;
            elsif fl5(1) = '1' then                                 -- kali: hanya digit puluh-ribuan
                data_r <= C_BLANK & C_BLANK & C_BLANK & d4;
            elsif fl5(0) = '1' or d3 /= x"0" then                   -- 4 digit penuh
                data_r <= d3 & d2 & d1 & d0;
            elsif d2 /= x"0" then
                data_r <= sgn & d2 & d1 & d0;
            elsif d1 /= x"0" then
                data_r <= C_BLANK & sgn & d1 & d0;
            else
                data_r <= C_BLANK & C_BLANK & sgn & d0;
            end if;
        end if;
    end process;

    data <= data_r;
end Behavioral;