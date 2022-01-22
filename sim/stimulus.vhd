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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stimulus is
    Port ( data_rdy : in STD_LOGIC;
           i2c_data : in STD_LOGIC_VECTOR (11 downto 0);
           rng_data : in STD_LOGIC_VECTOR (11 downto 0);
           rng_rdy : in STD_LOGIC;
           rng_en : out STD_LOGIC;
           no_of_samples : out STD_LOGIC_VECTOR (3 downto 0);
           rdy_for_data : out STD_LOGIC);
end stimulus;

architecture Behavioral of stimulus is

    signal i2c_reg, rng_reg : STD_LOGIC_VECTOR (11 downto 0);

    procedure compare_and_log is 
    begin 
    end procedure;

begin
    process 
        variable i, j : integer := 0;
        variable no_of_samples_buf : std_logic_vector(3 downto 0);
    begin 
        rng_en <= '0';
        i := 1;
        wait for 10 ns;
        while i < 16 loop

            no_of_samples_buf := std_logic_vector(to_unsigned(i, 4));
            no_of_samples <= no_of_samples_buf;
            j := 0;
            while j < to_integer(unsigned(no_of_samples_buf)) loop 
                
                rng_reg <= rng_data; -- saving currently sampled rng data 
                --
                rng_en <= '1'; -- generate new number 
                wait until rng_rdy = '1';
                rng_en <= '0';
                rdy_for_data <= '1';
                
                wait until data_rdy = '1';
                i2c_reg <= i2c_data;
                compare_and_log;
                
                wait until data_rdy = '0'; -- master in ready
                rdy_for_data <= '0';
                
                wait for 10 ns;
                
                j := j + 1;
            end loop;
            
            
            
            i := i + 1;
        end loop;
        wait;
    end process;

end Behavioral;
