----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.09.2026 22:41:28
-- Design Name: 
-- Module Name: mux4to1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4to1 is
    Port (
        sel : in  STD_LOGIC_VECTOR (1 downto 0);
        in0 : in  STD_LOGIC_VECTOR (3 downto 0);
        in1 : in  STD_LOGIC_VECTOR (3 downto 0);
        in2 : in  STD_LOGIC_VECTOR (3 downto 0);
        in3 : in  STD_LOGIC_VECTOR (3 downto 0);
        y   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end mux4to1;

architecture Behavioral of mux4to1 is
begin

    process(sel, in0, in1, in2, in3)
    begin
        case sel is
            when "00" =>
                y <= in0;

            when "01" =>
                y <= in1;

            when "10" =>
                y <= in2;

            when "11" =>
                y <= in3;

            when others =>
                y <= (others => '0');
        end case;
    end process;

end Behavioral;