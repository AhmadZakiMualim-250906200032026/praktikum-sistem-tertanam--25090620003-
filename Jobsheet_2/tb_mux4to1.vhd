----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.09.2026 22:47:01
-- Design Name: 
-- Module Name: tb_mux4to1 - Behavioral
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

entity tb_mux4to1 is
end tb_mux4to1;

architecture sim of tb_mux4to1 is

    signal sel_tb : STD_LOGIC_VECTOR (1 downto 0);
    signal in0_tb : STD_LOGIC_VECTOR (3 downto 0);
    signal in1_tb : STD_LOGIC_VECTOR (3 downto 0);
    signal in2_tb : STD_LOGIC_VECTOR (3 downto 0);
    signal in3_tb : STD_LOGIC_VECTOR (3 downto 0);
    signal y_tb   : STD_LOGIC_VECTOR (3 downto 0);

begin

    DUT: entity work.mux4to1
        port map (
            sel => sel_tb,
            in0 => in0_tb,
            in1 => in1_tb,
            in2 => in2_tb,
            in3 => in3_tb,
            y   => y_tb
        );

    stim_proc: process
    begin

        -- Memberikan nilai pada setiap input
        in0_tb <= "0001";
        in1_tb <= "0010";
        in2_tb <= "0100";
        in3_tb <= "1000";

        -- Skenario 1: sel = 00
        sel_tb <= "00";
        wait for 50 ns;

        assert y_tb = in2_tb
            report "ERROR: Output y tidak sesuai dengan in0"
            severity error;

        -- Skenario 2: sel = 01
        sel_tb <= "01";
        wait for 50 ns;

        assert y_tb = in1_tb
            report "ERROR: Output y tidak sesuai dengan in1"
            severity error;

        -- Skenario 3: sel = 10
        sel_tb <= "10";
        wait for 50 ns;

        assert y_tb = in2_tb
            report "ERROR: Output y tidak sesuai dengan in2"
            severity error;

        -- Skenario 4: sel = 11
        sel_tb <= "11";
        wait for 50 ns;

        assert y_tb = in3_tb
            report "ERROR: Output y tidak sesuai dengan in3"
            severity error;

        wait;

    end process;

end sim;