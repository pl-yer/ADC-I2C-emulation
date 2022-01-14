library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adc is
    generic (
        ADDRESS : std_logic_vector(6 downto 0) := "1001101"
    );
    port (
        scl : inout std_logic;
        sda : inout std_logic;
        rng_data : in std_logic_vector(11 downto 0)
    );
end adc;

architecture adc_arch of adc is

    signal clk : std_logic := '0';
    type state_t is (IDLE, CHECK_HEADER, TX_ACK, SEND_DATA, RX_ACK, STOP);
    signal state, state_nxt : state_t := IDLE;
    signal sda_prev, sda_reg : std_logic;
    signal scl_prev, scl_reg : std_logic;
    signal bit_count : integer range 0 to 8 := 0;
    signal header_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal polling : std_logic := '0';
    signal data_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal first_byte : std_logic := '1';
    signal exit_rx_ack : std_logic := '0';

begin
    
    CLK_GEN : process 
    begin
        wait for 1.25 us;
        clk <= not clk;
    end process;

    SYNC_STATE : process(clk)
    begin
        if rising_edge(clk) then
            state <= state_nxt;
            sda_reg <= sda;
            sda_prev <= sda_reg;
            scl_reg <= scl;
            scl_prev <= scl_reg;
        end if;
    end process;

    NEXT_STATE_DECODE : process(state, sda_reg, scl_reg, scl_prev, sda_prev) is
    begin
        state_nxt <= state;

        case state is
            when IDLE => 
                if sda_prev = 'H' and sda_reg = '0' and scl_prev = '1' and scl_reg = '1' then
                    bit_count <= 0;
                    header_reg <= (others => '0');
                    state_nxt <= CHECK_HEADER;
                else
                    state_nxt <= IDLE;
                end if;
            when CHECK_HEADER =>
                if bit_count = 8 then
                    if header_reg = (ADDRESS & '1') then
                        polling <= '0';
                        state_nxt <= TX_ACK;
                    elsif header_reg = (ADDRESS & '0') then
                        polling <= '1';
                        state_nxt <= TX_ACK;
                    else 
                        state_nxt <= IDLE;
                    end if;
                elsif sda_prev = sda_reg and scl_prev = '1' and scl_reg = '1' then
                    bit_count <= bit_count + 1;
                    if bit_count < 8 then
                        header_reg(7-bit_count) <= '1' when sda_reg = 'H' else '0';
                        state_nxt <= CHECK_HEADER;
                    end if;
                else
                    state_nxt <= CHECK_HEADER;
                end if;
            when TX_ACK =>
                if scl_prev = '1' and scl_reg = '0' then
                    if polling = '1' then
                        state_nxt <= IDLE;
                    else
                        data_reg(data_reg'LEFT-4 downto 0) <= rng_data;
                        bit_count <= 0;
                        first_byte <= '1';
                        state_nxt <= SEND_DATA;
                    end if;
                else
                    state_nxt <= TX_ACK;
                end if;
            when SEND_DATA =>
                if scl_prev = '1' and scl_reg = '0' then
                    if bit_count = 7 then
                        state_nxt <= RX_ACK;
                    else 
                        bit_count <= bit_count + 1;
                        state_nxt <= SEND_DATA;
                    end if;
                else
                    state_nxt <= SEND_DATA;
                end if;
            when RX_ACK =>
                if scl_prev = '1' and scl_reg = '0' and exit_rx_ack = '1' then
                    state_nxt <= SEND_DATA;
                elsif sda_reg = sda_prev and scl_prev = '1' and scl_reg = '1'  then
                    if sda_reg = '0' then
                        bit_count <= 0;
                        state_nxt <= RX_ACK;
                        exit_rx_ack <= '1';
                        if first_byte = '1' then
                            first_byte <= '0';
                        elsif first_byte = '0' then
                            first_byte <=  '1';
                            data_reg(data_reg'LEFT-4 downto 0) <= rng_data;
                        end if;
                    elsif sda_reg = 'H' then
                        state_nxt <= IDLE;
                    end if;
                else
                    state_nxt <= RX_ACK;
                end if;
            when STOP => 
                if sda_reg = 'H' and sda_prev = '0' and scl_prev = '1' and scl_reg = '1' then
                    state_nxt <= IDLE;
                else
                    state_nxt <= STOP;
                end if;
            when others =>
                assert false
                report ("I2C: entered not valid state") severity error;
                state_nxt <= IDLE;
        end case;
    end process;

    OUTPUT_DECODE : process(state, bit_count) is
    begin
        scl <= 'H';
        case state is
            when TX_ACK =>
                sda <= '0';
            when SEND_DATA =>
                if first_byte = '1' then
                    sda <= 'H' when data_reg(15-bit_count) = '1' else '0';
                else 
                    sda <='H' when data_reg(7-bit_count) = '1' else '0';
                end if;
            when others =>
                sda <= 'H';
        end case;
    end process;

end adc_arch;