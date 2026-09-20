library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu4x is
    Port ( a         : in  STD_LOGIC_VECTOR(3 downto 0);
           b         : in  STD_LOGIC_VECTOR(3 downto 0);
           opcode    : in  STD_LOGIC_VECTOR(1 downto 0); -- 00=+, 01=-, 10=*
           result    : out STD_LOGIC_VECTOR(3 downto 0); -- 4 LSB
           result_hi : out STD_LOGIC_VECTOR(3 downto 0); -- 4 MSB (untuk kali)
           carry     : out STD_LOGIC );
end alu4x;

architecture Behavioral of alu4x is
    signal a_u, b_u : unsigned(3 downto 0);
    signal sum_ext  : unsigned(4 downto 0);
    signal prod     : unsigned(7 downto 0);
begin
    a_u <= unsigned(a);
    b_u <= unsigned(b);

    process(a_u, b_u, opcode)
    begin
        sum_ext <= (others => '0');
        prod    <= (others => '0');
        case opcode is
            when "00"   => sum_ext <= ('0' & a_u) + ('0' & b_u);
            when "01"   => sum_ext <= ('0' & a_u) - ('0' & b_u);
            when "10"   => prod    <= a_u * b_u;
            when others => null;                       -- opcode 11: tidak dipakai
        end case;
    end process;

    result    <= STD_LOGIC_VECTOR(prod(3 downto 0)) when opcode = "10"
                 else STD_LOGIC_VECTOR(sum_ext(3 downto 0));
    result_hi <= STD_LOGIC_VECTOR(prod(7 downto 4));
    carry     <= sum_ext(4);
end Behavioral;