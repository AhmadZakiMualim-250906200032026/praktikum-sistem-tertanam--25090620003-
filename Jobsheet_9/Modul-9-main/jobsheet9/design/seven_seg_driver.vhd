library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Generic ( DIGITS      : integer := 4;
              CLK_FREQ_HZ : integer := 100_000_000;
              REFRESH_HZ  : integer := 1000 );
    Port ( clk  : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (4*DIGITS-1 downto 0);
           dots : in  STD_LOGIC_VECTOR (DIGITS-1 downto 0);
           seg  : out STD_LOGIC_VECTOR (6 downto 0);
           dp   : out STD_LOGIC;
           an   : out STD_LOGIC_VECTOR (DIGITS-1 downto 0) );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    constant DIV : integer := CLK_FREQ_HZ / REFRESH_HZ;
    signal tick_cnt : integer range 0 to DIV-1 := 0;
    signal idx      : integer range 0 to DIGITS-1 := 0;
    signal nib      : unsigned(3 downto 0) := (others => '0');

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
            when others => return "0001110"; -- F
        end case;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if tick_cnt = DIV-1 then
                tick_cnt <= 0;
                if idx = DIGITS-1 then idx <= 0; else idx <= idx + 1; end if;
            else
                tick_cnt <= tick_cnt + 1;
            end if;
        end if;
    end process;

    process(idx, data)
    begin
        nib <= (others => '0');
        for i in 0 to DIGITS-1 loop
            if i = idx then
                nib <= unsigned(data(4*i+3 downto 4*i));
            end if;
        end loop;
    end process;

    process(idx, nib, dots)
    begin
        an <= (others => '1');
        an(idx) <= '0';
        seg <= hex_to_seg(nib);
        dp  <= not dots(idx);
    end process;
end Behavioral;
