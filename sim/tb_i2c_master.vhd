
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity tb_i2c_master is
end tb_i2c_master;

architecture bench of tb_i2c_master is

    signal sda : std_logic := 'H';
    signal scl : std_logic := 'H';

begin

    DUT : entity work.i2c_master
        port map(
            reset => '0',
            --communication with stimulus
            rdy_for_data => '0',
            data_rdy => open,
            i2c_data => open, 
            --i2c communtiation interface        
            sda => sda,
            scl => scl      
        );

    -- SDA_PULLUP : PULLUP
    -- port map (
    -- O => sda_c -- Pullup output (connect directly to top-level port)
    -- );

    -- SCL_PULLUP : PULLUP
    -- port map (
    -- O => scl_c -- Pullup output (connect directly to top-level port)
    -- );


end bench;