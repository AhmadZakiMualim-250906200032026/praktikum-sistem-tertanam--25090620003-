----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2026 17:53:15
-- Design Name: 
-- Module Name: tb_tugas2 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity tb_tugas2 is
end tb_tugas2;

architecture sim of tb_tugas2 is
    constant T_PCLK  : time := 40 ns;            -- 25 MHz
    constant T_FRAME : time := 525 * 800 * T_PCLK;  -- 16,8 ms

    signal pclk     : std_logic := '0';
    signal rst      : std_logic := '1';
    signal mode     : std_logic := '0';
    signal sw       : std_logic_vector(3 downto 0) := "0000";
    signal hsync, vsync, video_on : std_logic;
    signal h_count  : integer range 0 to 1055;
    signal v_count  : integer range 0 to 627;
    signal box_on   : std_logic;
    signal rgb_out  : std_logic_vector(11 downto 0);
    signal done     : boolean := false;
begin
    u_sync : entity work.vga_sync_multi
        port map ( pclk => pclk, rst => rst, mode => mode,
                   hsync => hsync, vsync => vsync, video_on => video_on,
                   h_count => h_count, v_count => v_count );

    u_box : entity work.box_indicator
        port map ( h_count => h_count, v_count => v_count,
                   sw => sw, mode => mode, box_on => box_on );

    rgb_out <= x"F00" when (box_on = '1' and video_on = '1') else x"000";

    clk_gen : process
    begin
        while not done loop
            pclk <= '0'; wait for T_PCLK/2;
            pclk <= '1'; wait for T_PCLK/2;
        end loop;
        wait;
    end process;

    -- kotak 40x40 di X = sw*40, Y = 220 (mode 640x480)
    chk : process(pclk)
        variable bx : integer;
        variable exp_on : boolean;
    begin
        if falling_edge(pclk) then
            bx := to_integer(unsigned(sw)) * 40;
            exp_on := (h_count >= bx) and (h_count < bx + 40) and
                      (v_count >= 220) and (v_count < 260);
            assert (box_on = '1') = exp_on
                report "box_on tidak sesuai posisi kotak" severity error;
        end if;
    end process;

    stim : process
    begin
        rst <= '1'; wait for 200 ns;
        rst <= '0';
        sw <= "0000"; wait for T_FRAME;   -- frame 1
        sw <= "1000"; wait for T_FRAME;   -- frame 2
        sw <= "1111"; wait for T_FRAME;   -- frame 3
        done <= true;
        report "SELESAI Tugas 2" severity note;
        wait;
    end process;
end sim;
