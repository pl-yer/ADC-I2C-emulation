library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adc is
    port (
        scl : in std_logic;
        sda : inout std_logic;
        rng_data : in std_logic_vector(11 downto 0)
    );
end adc;

architecture adc_arch of adc is

begin
end adc_arch;