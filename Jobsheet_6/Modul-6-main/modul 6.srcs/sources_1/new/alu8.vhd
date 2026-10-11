-- ALU 8-bit kombinasional: tambah, kurang, kali.
-- (Pembagian dikerjakan bertahap di calculator_fsm supaya timing 100 MHz terpenuhi.)
-- op: "00"=tambah, "01"=kurang, "11"=kali
-- kali: y = a*b (16-bit, 0..65025), flag = 0 (indikator hasil > 9999 dibuat di disp_dec)
-- tambah: y = 0 & (a+b)  (bit 8 = carry)
-- kurang: y = 00 & (a-b) (flag=1 jika a<b / borrow)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu8 is
    Port ( a, b : in  STD_LOGIC_VECTOR(7 downto 0);
           op   : in  STD_LOGIC_VECTOR(1 downto 0);
           y    : out STD_LOGIC_VECTOR(15 downto 0);
           flag : out STD_LOGIC );
end alu8;

architecture Behavioral of alu8 is
    signal sum, dif : unsigned(8 downto 0);
    signal prod     : unsigned(15 downto 0);
begin
    sum <= ('0' & unsigned(a)) + ('0' & unsigned(b));
    dif <= ('0' & unsigned(a)) - ('0' & unsigned(b));
    prod <= unsigned(a) * unsigned(b);

    y <= "0000000" & std_logic_vector(sum)     when op = "00" else
         x"00" & std_logic_vector(dif(7 downto 0)) when op = "01" else
         std_logic_vector(prod)                    when op = "11" else
         x"0000";
    flag <= dif(8) when op = "01" else '0';
end Behavioral;