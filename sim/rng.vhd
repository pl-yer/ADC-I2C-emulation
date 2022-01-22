----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/13/2022 02:11:30 PM
-- Design Name: 
-- Module Name: rng - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rng is
    Port ( rng_en : in STD_LOGIC;
           rng_rdy : out STD_LOGIC;
           rng_data : out STD_LOGIC_VECTOR (11 downto 0));
end rng;

architecture Behavioral of rng is
begin
    process
        variable data : integer := 1365;
    begin 
        wait until rising_edge(rng_en);
        rng_rdy <= '0';
        wait for 10 ns;
        rng_data <= std_logic_vector(to_unsigned(data, rng_data'length));
        data := data + 1;
        rng_rdy <= '1';
    end process;

end Behavioral;
