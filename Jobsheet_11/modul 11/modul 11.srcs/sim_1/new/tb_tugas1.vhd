----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2026 17:30:33
-- Design Name: 
-- Module Name: tb_tugas1 - Behavioral
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

entity tb_tugas1 is
end tb_tugas1;

architecture sim of tb_tugas1 is
    constant T_PCLK : time := 40 ns;   -- 25 MHz
    signal pclk     : std_logic := '0';
    signal rst      : std_logic := '1';
    signal mode     : std_logic := '0';
    signal hsync, vsync, video_on : std_logic;
    signal h_count  : integer range 0 to 1055;
    signal v_count  : integer range 0 to 627;
    signal rgb_chk  : std_logic_vector(11 downto 0);
    signal rgb_out  : std_logic_vector(11 downto 0);
    signal done     : boolean := false;
begin
    u_sync : entity work.vga_sync_multi
        port map ( pclk => pclk, rst => rst, mode => mode,
                   hsync => hsync, vsync => vsync, video_on => video_on,
                   h_count => h_count, v_count => v_count );

    u_chk : entity work.checkerboard_pattern
        port map ( h_count => h_count, v_count => v_count, rgb => rgb_chk );

    rgb_out <= rgb_chk when video_on = '1' else x"000";

    clk_gen : process
    begin
        while not done loop
            pclk <= '0'; wait for T_PCLK/2;
            pclk <= '1'; wait for T_PCLK/2;
        end loop;
        wait;
    end process;

    -- kotak 32x32: warna putih bila bit-5 h_count berbeda dari bit-5 v_count
    chk : process(pclk)
    begin
        if falling_edge(pclk) then
            assert (rgb_chk = x"FFF") = (((h_count/32) mod 2) /= ((v_count/32) mod 2))
                report "Pola papan catur tidak sesuai" severity error;
        end if;
    end process;

    stim : process
    begin
        rst <= '1'; wait for 200 ns;
        rst <= '0'; wait for 1200 us;   -- cukup melewati baris ke-32 (sekitar 1,024 ms)
        done <= true;
        report "SELESAI Tugas 1" severity note;
        wait;
    end process;
end sim;
