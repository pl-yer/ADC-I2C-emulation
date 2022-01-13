----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/13/2022 01:01:36 PM
-- Design Name: 
-- Module Name: stimulus - Behavioral
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

entity stimulus is
    Port ( no_of_samples : out STD_LOGIC_VECTOR (3 downto 0);
           rdy_for_data : out STD_LOGIC;
           data_rdy : in STD_LOGIC;
           i2c_data : in STD_LOGIC_VECTOR (11 downto 0);
           rng_data : in STD_LOGIC_VECTOR (11 downto 0));
end stimulus;

architecture Behavioral of stimulus is

begin


end Behavioral;
