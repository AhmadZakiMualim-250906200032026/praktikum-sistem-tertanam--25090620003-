-- Langkah 6: testbench skenario lengkap (tambah, kurang, bagi, kali, bagi-nol).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_calculator_fsm is
end tb_calculator_fsm;

architecture sim of tb_calculator_fsm is
    signal clk, rst : STD_LOGIC := '0';
    signal sw : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal pu, pd, pc : STD_LOGIC := '0';
    signal disp : STD_LOGIC_VECTOR(15 downto 0);
    signal flag : STD_LOGIC;
    signal state_led : STD_LOGIC_VECTOR(3 downto 0);
    constant T : time := 10 ns;

    procedure pulse(signal s : out STD_LOGIC; signal c : in STD_LOGIC) is
    begin
        wait until rising_edge(c);
        s <= '1';
        wait until rising_edge(c);
        s <= '0';
    end procedure;
begin
    clk <= not clk after T/2;

    DUT : entity work.calculator_fsm
        port map (clk => clk, rst => rst, sw => sw, pu => pu, pd => pd, pc => pc,
                  disp => disp, flag => flag, state_led => state_led,
                  op_out => open, show => open);

    process
        procedure run_op(a, b : STD_LOGIC_VECTOR(7 downto 0); op : STD_LOGIC_VECTOR(1 downto 0)) is
        begin
            sw <= op & "000000" & a;  pulse(pu, clk);   -- muat A
            sw <= op & "000000" & b;  pulse(pd, clk);   -- muat B
            pulse(pc, clk);                              -- hitung
            wait for 14*T;                               -- sampai S_SHOW
        end procedure;
    begin
        rst <= '1'; wait for 3*T; rst <= '0'; wait for 2*T;

        -- 15 + 1 = 16 (0x0010)
        run_op(x"0F", x"01", "00");
        assert disp = x"0010" report "ADD salah" severity error;
        pulse(pc, clk); wait for 2*T;

        -- 5 - 3 = 2
        run_op(x"05", x"03", "01");
        assert disp = x"0002" and flag = '0' report "SUB salah" severity error;
        pulse(pc, clk); wait for 2*T;

        -- 3 - 5 -> borrow
        run_op(x"03", x"05", "01");
        assert disp = x"00FE" and flag = '1' report "SUB borrow salah" severity error;
        pulse(pc, clk); wait for 2*T;

        -- 20 / 6 = 3 sisa 2 (0x0203)
        run_op(x"14", x"06", "10");
        assert disp = x"0203" report "DIV salah" severity error;
        pulse(pc, clk); wait for 2*T;

        -- 12 * 13 = 156 (0x009C)
        run_op(x"0C", x"0D", "11");
        assert disp = x"009C" and flag = '0' report "MUL salah" severity error;
        pulse(pc, clk); wait for 2*T;

        -- 255 * 255 = 65025 (0xFE01)
        run_op(x"FF", x"FF", "11");
        assert disp = x"FE01" report "MUL 255x255 salah" severity error;
        pulse(pc, clk); wait for 2*T;

        -- 7 / 0 -> error
        run_op(x"07", x"00", "10");
        assert disp = x"EEEE" and flag = '1' report "DIV0 salah" severity error;

        report "Simulasi selesai" severity note;
        wait;
    end process;
end sim;