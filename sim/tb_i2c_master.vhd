
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity tb_i2c_master is
end tb_i2c_master;

architecture bench of tb_i2c_master is

    signal sda_c, sda_o1, sda_o2 : std_logic;
    signal scl_c, scl_o1, scl_o2 : std_logic;

begin

    DUT : entity work.i2c_master
        port map(
            reset => '0',
            --communication with stimulus
            rdy_for_data => '0',
            data_rdy => open,
            i2c_data => open, 
            --i2c communtiation interface        
            sda_o => sda_o1,
            scl_o => scl_o1,
            sda_i => sda_c,
            scl_i => scl_c        
        );

    sda_c <= sda_o1 and sda_o2;
    scl_c <= scl_o1 and scl_o2;
    
    sda_o2 <= '1';
    scl_o2 <= '1';

    -- SDA_PULLUP : PULLUP
    -- port map (
    -- O => sda_c -- Pullup output (connect directly to top-level port)
    -- );

    -- SCL_PULLUP : PULLUP
    -- port map (
    -- O => scl_c -- Pullup output (connect directly to top-level port)
    -- );


end bench;