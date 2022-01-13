-- this module is a procedural testing module for i2c communication interface with adc emulator

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity i2c_master is
  port (
    --communication with stimulus
    no_of_samples : in std_logic_vector(3 downto 0);
    rdy_for_data : in std_logic;
    data_rdy : out std_logic;
    i2c_data : out std_logic_vector(11 downto 0);
    --i2c communtiation interface        
    sda : inout std_logic;
    scl : inout std_logic       
  );
end i2c_master;

architecture i2c_master_arch of i2c_master is

  constant CLK_PERIOD_100KHZ : time := 10 us;
  type t_RW is (READ, WRITE); 

  type t_state is (READY, ACQUSITION);

  signal clk : std_logic := '0';
  signal scl_on : std_logic := '0';  
  signal state : t_state := READY;
  signal sample_to_acq : integer;
  signal do_rd_or_wr : t_RW;

begin
    clk <= not clk after CLK_PERIOD_100KHZ/2;
    scl <= clk when scl_on = '1' else 'H'; 
    process
        procedure free_bus is
        begin
            sda <= 'H';
        end procedure;
    
        procedure send_start is
        begin
            wait until rising_edge(clk);
            scl_on <= '1';
            wait for CLK_PERIOD_100KHZ/4;
            sda <= '0';
            wait for CLK_PERIOD_100KHZ/4;
        end procedure;
    
        procedure send_address (slave_addr : in std_logic_vector(6 downto 0); rw : in t_RW) is
            variable data : std_logic_vector(7 downto 0);
            variable rw_sl : std_logic;
        begin
            if rw = READ then
                rw_sl := '1';
            else
                rw_sl := '0';
            end if;
            data := slave_addr & rw_sl;
            for i in 7 downto 0 loop
                wait until falling_edge(scl);
                wait for CLK_PERIOD_100KHZ/4;
                if data(i) = '1' then
                    sda <= 'H';
                else
                    sda <= '0';
                end if;
            end loop;
        end procedure;

        procedure read_byte (data_out : out std_logic_vector(7 downto 0)) is
        begin
            for i in 7 downto 0 loop
                wait until rising_edge(scl);
                free_bus;
                wait for CLK_PERIOD_100KHZ/4;
                data_out(i) := sda;  
            end loop;
        end procedure;

        procedure is_acknowledged(result : out boolean) is
        begin
            wait until rising_edge(scl);
            wait for CLK_PERIOD_100KHZ/4;
            result := sda = '0';
        end procedure;

        procedure do_acknowledge(result : in boolean) is
        begin
            wait until falling_edge(scl);
            wait for CLK_PERIOD_100KHZ/4;
            if result then
                sda <= '0';
            else 
                sda <= 'H';
            end if;
        end procedure;

        procedure send_stop is
        begin
            wait until falling_edge(clk);
            sda <= '0';
            scl_on <= '1';
            wait until rising_edge(clk);
            wait for CLK_PERIOD_100KHZ/4;
            sda <= 'H';
            wait for CLK_PERIOD_100KHZ/4;
        end procedure;

        variable result : boolean;
        variable data : std_logic_vector(15 downto 0);
        variable do_rd_or_wr_int : t_RW := do_rd_or_wr;
    begin
      while true loop
        wait for 1 ns;
        case state is
          when READY =>
            free_bus;
            wait until rdy_for_data = '1';
            state <= ACQUSITION;
            wait for CLK_PERIOD_100KHZ/8;
            sample_to_acq <= to_integer(unsigned(no_of_samples));
            if sample_to_acq = 0 then
              do_rd_or_wr <= WRITE;
              do_rd_or_wr_int := WRITE;
            else
              do_rd_or_wr <= READ;
              do_rd_or_wr_int := READ;
            end if;
            report "out ready";
          when ACQUSITION =>
            while true loop
              report "acq";
              send_start;
              report "start";
              send_address("1001101", do_rd_or_wr_int); -- read is acquisition ; write is polling
              report "address";
              is_acknowledged(result);
              if not result then --else retransmition
                  exit;
              end if; 
            end loop;
            if sample_to_acq = 0 then
              state <= READY;
              send_stop;
              exit;
            end if;
            read_byte(data(15 downto 8));
            do_acknowledge(true);
            read_byte(data(7 downto 0));
            if sample_to_acq > 0 then
              do_acknowledge(true);
            else
              do_acknowledge(false);
            end if;
            data_rdy <= '1';
            i2c_data <= to_stdlogicvector(to_bitvector(data(11 downto 0)));
            if sample_to_acq = 0 then
              state <= READY;
            else
              sample_to_acq <= sample_to_acq - 1;
            end if;
            send_stop;
        end case;
      end loop;
    end process;
end i2c_master_arch;