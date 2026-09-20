library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu4s is
    Port ( a        : in  STD_LOGIC_VECTOR(3 downto 0);
           b        : in  STD_LOGIC_VECTOR(3 downto 0);
           opcode   : in  STD_LOGIC;             -- '0'=tambah, '1'=kurang
           result   : out STD_LOGIC_VECTOR(3 downto 0);
           overflow : out STD_LOGIC );
end alu4s;

architecture Behavioral of alu4s is
    signal a_s, b_s : signed(3 downto 0);
    signal sum_ext  : signed(4 downto 0);
begin
    a_s <= signed(a);
    b_s <= signed(b);

    process(a_s, b_s, opcode)
    begin
        if opcode = '0' then
            sum_ext <= resize(a_s, 5) + resize(b_s, 5);
        else
            sum_ext <= resize(a_s, 5) - resize(b_s, 5);
        end if;
    end process;

    result <= STD_LOGIC_VECTOR(sum_ext(3 downto 0));

    -- Overflow signed: tanda hasil tidak konsisten dengan tanda operand
    overflow <= '1' when ((opcode = '0' and a(3) = b(3)) or
                          (opcode = '1' and a(3) /= b(3)))
                        and (sum_ext(3) /= a(3))
              else '0';
end Behavioral;