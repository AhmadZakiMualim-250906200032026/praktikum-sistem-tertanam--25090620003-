-- FSM kalkulator (Moore, 2-process style) + datapath.
-- sw(7:0)=operand, sw(15:14)=operasi (00 +, 01 -, 10 /, 11 x)
-- pu/pd/pc = pulsa 1 clock dari btnU/btnD/btnC (sudah debounce+edge)
-- S_COMPUTE berlangsung 9 clock: 8 clock iterasi pembagian (1 bit per clock),
-- 1 clock terakhir menyimpan hasil. Tambah/kurang memakai alu8 (kombinasional).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculator_fsm is
    Port ( clk, rst   : in  STD_LOGIC;
           sw         : in  STD_LOGIC_VECTOR(15 downto 0);
           pu, pd, pc : in  STD_LOGIC;
           disp       : out STD_LOGIC_VECTOR(15 downto 0);
           flag       : out STD_LOGIC;
           state_led  : out STD_LOGIC_VECTOR(3 downto 0);
           op_out     : out STD_LOGIC_VECTOR(1 downto 0);   -- operasi yang dipilih (untuk format tampilan)
           show       : out STD_LOGIC );                    -- '1' saat S_SHOW (disp = hasil)
end calculator_fsm;

architecture Behavioral of calculator_fsm is
    type calc_state is (S_WAIT_A, S_WAIT_B, S_COMPUTE, S_SHOW);
    signal state, next_state : calc_state := S_WAIT_A;

    signal reg_a, reg_b : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal op_reg       : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal res_reg      : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal flag_reg     : STD_LOGIC := '0';
    signal alu_y        : STD_LOGIC_VECTOR(15 downto 0);
    signal alu_f        : STD_LOGIC;
    signal rem_r        : unsigned(8 downto 0) := (others => '0');
    signal quo_r        : unsigned(7 downto 0) := (others => '0');
    signal cnt          : integer range 0 to 8 := 0;
    signal start_alu, show_en : STD_LOGIC;
begin
    U_ALU : entity work.alu8
        port map (a => reg_a, b => reg_b, op => op_reg, y => alu_y, flag => alu_f);

    -- PROCESS 1 (SINKRON): register state
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= S_WAIT_A;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    -- PROCESS 2 (KOMBINASIONAL): next_state + keluaran (Moore)
    process(state, pu, pd, pc, cnt)
    begin
        next_state <= state;
        start_alu  <= '0';
        show_en    <= '0';
        state_led  <= "0000";
        case state is
            when S_WAIT_A =>
                state_led <= "0001";
                if pu = '1' then next_state <= S_WAIT_B; end if;
            when S_WAIT_B =>
                state_led <= "0010";
                if pc = '1' then next_state <= S_COMPUTE; end if;
            when S_COMPUTE =>
                state_led <= "0100";
                start_alu <= '1';
                if cnt = 8 then next_state <= S_SHOW; end if;
            when S_SHOW =>
                state_led <= "1000";
                show_en   <= '1';
                if pc = '1' or pu = '1' then next_state <= S_WAIT_A; end if;
        end case;
    end process;

    -- DATAPATH (sinkron)
    process(clk)
        variable v : unsigned(8 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_a <= (others => '0');
                reg_b <= (others => '0');
                op_reg <= "00";
                res_reg  <= (others => '0');
                flag_reg <= '0';
                rem_r <= (others => '0');
                quo_r <= (others => '0');
                cnt   <= 0;
            else
                if state = S_WAIT_A and pu = '1' then reg_a <= sw(7 downto 0); end if;
                if state = S_WAIT_B and pd = '1' then reg_b <= sw(7 downto 0); end if;
                if state = S_WAIT_B and pc = '1' then op_reg <= sw(15 downto 14); end if;

                if state = S_COMPUTE then
                    if cnt < 8 then
                        -- satu iterasi pembagian restoring per clock
                        v := rem_r(7 downto 0) & reg_a(7 - cnt);
                        if v >= ('0' & unsigned(reg_b)) then
                            rem_r <= v - ('0' & unsigned(reg_b));
                            quo_r(7 - cnt) <= '1';
                        else
                            rem_r <= v;
                            quo_r(7 - cnt) <= '0';
                        end if;
                        cnt <= cnt + 1;
                    else
                        -- simpan hasil
                        if op_reg = "10" then
                            if reg_b = x"00" then
                                res_reg  <= x"EEEE";
                                flag_reg <= '1';
                            else
                                res_reg  <= std_logic_vector(rem_r(7 downto 0)) & std_logic_vector(quo_r);
                                flag_reg <= '0';
                            end if;
                        else
                            res_reg  <= alu_y;
                            flag_reg <= alu_f;
                        end if;
                        cnt <= 0;
                    end if;
                else
                    cnt   <= 0;
                    rem_r <= (others => '0');
                    quo_r <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    disp <= res_reg when show_en = '1' else x"00" & sw(7 downto 0);
    flag <= flag_reg when show_en = '1' else '0';
    op_out <= op_reg;
    show   <= show_en;
end Behavioral;