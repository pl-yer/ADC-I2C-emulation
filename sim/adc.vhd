library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adc is
    generic (
        MASTER_BYTE : std_logic_vector(7 downto 0) := "10011011";
        CLK_PERIOD : time := 10 us
    );
    port (
        scl : inout std_logic;
        sda : inout std_logic;
        rng_data : in std_logic_vector(11 downto 0)
    );
end adc;

architecture adc_arch of adc is

    signal clk : std_logic := '0';
    signal input_data : std_logic_vector(15 downto 0);
    type input_byte_t is (FIRST, SECOND);
    signal data_byte : input_byte_t := FIRST;
    signal sda_buff, sda_prev, sda_output : std_logic := '1';
    signal sda_enable : std_logic := '0';

begin
    internal_clk : process(clk) is
    begin
        clk <= not clk after CLK_PERIOD/2;
    end process;

    sda_buffer : process(clk) is
    begin
        if rising_edge(clk) then
            sda_buff <= sda;
            sda_prev <= sda_buff;
        end if;
    end process;

    process is
        procedure check_start(is_start : out boolean) is
        begin
            -- is_start := sda'event and sda = '0';
            is_start := sda_prev = '1' and sda_buff = '0';
        end procedure;

        procedure check_bus(is_free : out boolean) is 
        begin
            is_free := scl = 'Z' and sda = 'Z';
        end procedure;

        procedure check_addr_n_mode(is_match : out boolean) is
            variable master_data : std_logic_vector(7 downto 0);
        begin
            for i in 7 downto 0 loop
                wait until rising_edge(scl);
--                wait for CLK_PERIOD/4;
                master_data(i) := sda;
            end loop;
            is_match := master_data = MASTER_BYTE;
        end procedure;

        procedure sample_input is
        begin
            wait until falling_edge(scl);
            wait for CLK_PERIOD/4;
            -- wait for 1.12 us; -- ACQ time
            -- wait for 8.96 us; -- CONV time
            input_data(input_data'LEFT downto (input_data'LEFT-rng_data'LENGTH+1)) <= rng_data;
        end procedure;

        procedure send_ACK is
        begin
            sda_enable <= '1';
--            wait for CLK_PERIOD/4;
--            wait until falling_edge(scl);
--            wait for CLK_PERIOD/4;
            sda_output <= '0';
        end procedure;

        procedure send_data_byte(data_byte : in input_byte_t) is
            variable index_MSB, index_LSB : integer;
        begin
            sda_enable <= '1';
            if data_byte = FIRST then
                index_LSB := 8;
                index_MSB := 15;
            else
                index_LSB := 0;
                index_MSB := 7;
            end if;

            for i in index_MSB downto index_LSB loop
                wait until falling_edge(scl);
                wait for CLK_PERIOD/4;
                sda_output <= input_data(i);
            end loop;
        end procedure;

        procedure check_ACK(is_ACK : out boolean) is
        begin
            wait until rising_edge(scl);
            wait for CLK_PERIOD/4;
            is_ACK := sda = '0';
        end procedure;

        variable is_start, is_free, is_match, is_ACK : boolean;

    begin
--        if rising_edge(clk) then
            -- check_bus(is_free);
            sda_enable <= '0';
            wait for CLK_PERIOD/4;
            -- if is_free = true then
                check_start(is_start);
                if is_start = true then
                    check_addr_n_mode(is_match);
                    if is_match = true then
                        sample_input;
                        send_ACK;
                        send_data_byte(data_byte);
                        check_ACK(is_ACK);
                        if is_ACK = true then
                            data_byte <= SECOND;
                            send_data_byte(data_byte);
                        end if;
                    end if;
                end if;
            -- end if;
--        end if;
    end process;

    sda <= sda_output when sda_enable = '1' else 'Z';
    scl <= 'Z';

end adc_arch;