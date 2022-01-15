----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/13/2022 01:01:36 PM
-- Design Name: 
-- Module Name: testbench - Structural
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench is
end testbench;

architecture Structural of testbench is
    component stimulus is
    Port ( data_rdy : in STD_LOGIC;
           i2c_data : in STD_LOGIC_VECTOR (11 downto 0);
           rng_data : in STD_LOGIC_VECTOR (11 downto 0);
           rng_rdy : in STD_LOGIC;
           rng_en : out STD_LOGIC;
           no_of_samples : out STD_LOGIC_VECTOR (3 downto 0);
           rdy_for_data : out STD_LOGIC);
    end component;
    
    component i2c_master is
    port (
        reset : in std_logic;
        --communication with stimulus
        no_of_samples : out STD_LOGIC_VECTOR (3 downto 0);
        rdy_for_data : in std_logic;
        data_rdy : out std_logic;
        i2c_data : out std_logic_vector(11 downto 0);
        --i2c communtiation interface        
        sda : inout std_logic;
        scl : inout std_logic       
    );
    end component;
    
    component rng is
    Port ( rng_en : in STD_LOGIC;
        rng_rdy : out STD_LOGIC;
        rng_data : out STD_LOGIC_VECTOR (11 downto 0));
    end component;
    
--    component adc
--    end component;    
    
begin
    

end Structural;
