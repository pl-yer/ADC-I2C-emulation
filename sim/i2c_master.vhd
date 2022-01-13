-- this module is a procedural testing module for i2c communication interface with adc emulator

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2c_master is
  generic(
    cont_mode : boolean := false
  );
  port (
    reset : in std_logic;
    --communication with stimulus
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

  signal clk : std_logic := '0';
  signal scl_on : std_logic := '0';  

begin

    clk <= not clk after CLK_PERIOD_100KHZ/2;
    scl <= clk when scl_on = '1' else 'H'; 
    process
        procedure free_bus is
        begin
            -- scl_o <= '1';
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
                sda <= 'H' when data(i) = '1' else '0';  
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

        variable result : boolean;
        variable data : std_logic_vector(15 downto 0);
    begin
        free_bus;
        wait for 10 ns;   
        while true loop
            send_start;
            send_address("1001101", READ);
            is_acknowledged(result);
            if result then --else retransmition
                exit;
            end if; 
        end loop;
            read_byte(data(15 downto 8));
            do_acknowledge(true);
            read_byte(data(7 downto 0));
            do_acknowledge(cont_mode);
            data_rdy <= '1';
            i2c_data <= data(11 downto 0);
        wait;
    end process;
end i2c_master_arch;