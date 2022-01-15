
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_i2c_master is
end tb_i2c_master;

architecture bench of tb_i2c_master is

    signal rdy_for_data : std_logic := '0';
    signal sda : std_logic := 'H';
    signal scl : std_logic := 'H';

begin

    DUT1 : entity work.i2c_master
        port map(
            --communication with stimulus
            no_of_samples => std_logic_vector(to_unsigned(3, 4)),
            rdy_for_data => rdy_for_data,
            data_rdy => open,
            i2c_data => open, 
            --i2c communtiation interface        
            sda => sda,
            scl => scl      
        );

    DUT2 : entity work.adc
        generic map(
            ADDRESS => "1001101"
        )
        port map(
            scl => scl,
            sda => sda,
            rng_data => "101010101010"
        );

    process
    begin
        wait for 10 us;
        rdy_for_data <= '1';
        wait for 30 us;
        rdy_for_data <= '0';
        wait;
    end process;

end bench;