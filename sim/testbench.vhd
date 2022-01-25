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
           rdy_for_data : out STD_LOGIC;
           rng_clk : out STD_LOGIC;
            rst : out std_logic);
    end component;
    
    component i2c_master is
    port (
        --communication with stimulus
        no_of_samples : in std_logic_vector(3 downto 0);
        rdy_for_data : in std_logic;
        data_rdy : out std_logic;
        i2c_data : out std_logic_vector(11 downto 0);
        --i2c communtiation interface        
        sda : inout std_logic;
        scl : inout std_logic); 
    end component;
    
    component rng is
    Generic (
        ADDRESS : std_logic_vector(6 downto 0) := "1001101");
    Port ( clk : in std_logic;
        rst : in std_logic;
        rng_en : in std_logic;
        rng_data : buffer std_logic_vector(3 downto 0);
        rng_rdy : out std_logic;
        rng_adc : out std_logic_vector(11 downto 0));
    end component;
    
    component adc is
    generic (
        ADDRESS : std_logic_vector(6 downto 0) := "1001101"
    );
    port (
        scl : inout std_logic;
        sda : inout std_logic;
        rng_data : in std_logic_vector(11 downto 0));
    end component;    
    
    signal rng_en, data_rdy, rng_rdy, rdy_for_data, sda, scl, rng_clk, rng_rst : std_logic;
    signal i2c_data, rng_data : std_logic_vector (11 downto 0);
    signal no_of_samples : std_logic_vector (3 downto 0);
    
begin
    dut_master : i2c_master
        port map (no_of_samples => no_of_samples,
        rdy_for_data => rdy_for_data,
        data_rdy => data_rdy,
        i2c_data => i2c_data,
        sda => sda,
        scl => scl);
    
    dut_adc : adc
        port map ( scl => scl,
        sda => sda,
        rng_data => rng_data);
        
    dut_stimulus : stimulus
        port map ( data_rdy => data_rdy,
        i2c_data => i2c_data,
        rng_data => rng_data,
        rng_rdy => rng_rdy,
        rng_en => rng_en,
        no_of_samples => no_of_samples,
        rdy_for_data => rdy_for_data,
        rng_clk => rng_clk,
        rst => rng_rst);
        
    dut_rng : rng 
        port map ( clk => rng_clk,
        rst => rng_rst,
        rng_en => rng_en,
--        rng_data => rng_data,
        rng_rdy => rng_rdy,
        rng_adc => rng_data);

end Structural;
