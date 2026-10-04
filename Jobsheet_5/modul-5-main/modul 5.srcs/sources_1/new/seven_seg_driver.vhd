library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Generic ( DIGITS      : integer := 4;
              CLK_FREQ_HZ : integer := 100_000_000;
              REFRESH_HZ  : integer := 1000 );
    Port ( clk   : in  STD_LOGIC;
           value : in  STD_LOGIC_VECTOR(4*DIGITS-1 downto 0);
           seg   : out STD_LOGIC_VECTOR(6 downto 0);
           dp    : out STD_LOGIC;
           an    : out STD_LOGIC_VECTOR(3 downto 0) );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    constant DIV_LIMIT : integer := CLK_FREQ_HZ / REFRESH_HZ - 1;
    signal cnt       : integer range 0 to DIV_LIMIT := 0;
    signal digit_idx : integer range 0 to DIGITS-1 := 0;
    signal nibble    : unsigned(3 downto 0) := (others => '0');

    function hex_to_seg(digit : unsigned(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case digit is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when "1010" => return "0001000"; -- A
            when "1011" => return "0000011"; -- b
            when "1100" => return "1000110"; -- C
            when "1101" => return "0100001"; -- d
            when "1110" => return "0000110"; -- E
            when "1111" => return "0001110"; -- F
            when others => return "0111111"; -- '-'
        end case;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if cnt = DIV_LIMIT then
                cnt <= 0;
                if digit_idx = DIGITS-1 then
                    digit_idx <= 0;
                else
                    digit_idx <= digit_idx + 1;
                end if;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    process(digit_idx, value)
    begin
        an <= "1111";
        an(digit_idx) <= '0';
        case digit_idx is
            when 0      => nibble <= unsigned(value(3 downto 0));
            when 1      => nibble <= unsigned(value(7 downto 4));
            when 2      => nibble <= unsigned(value(11 downto 8));
            when others => nibble <= unsigned(value(15 downto 12));
        end case;
    end process;

    seg <= hex_to_seg(nibble);
    dp  <= '1';
end Behavioral;