----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 02:01:57 PM
-- Design Name: 
-- Module Name: test_processor - Behavioral
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

entity test_processor is
--  Port ( );
end test_processor;

architecture Behavioral of test_processor is

    component processor is
    Port ( clk: in std_logic; 
    reset : in STD_LOGIC );
    end component;
    
    signal reset_test : std_logic;
    
    signal Clock_test: std_logic := '0';
    constant Clock_period : time := 10 ns;
begin
    processor_uut: processor port map (
        clk => Clock_test,
        reset => reset_test
    );
    
    -- NOTE: You can view the internal values in the simulation.
    -- Checkout the scope and objects tab. Drag to timeline.
    -- resimulate their values using the play button (top menu bar)
    
    Clock_process : process
    begin
        Clock_test <= not(Clock_test);
        wait for Clock_period/2;
    end process;
    
    reset_test <= '0', '1' after 50ns;

end Behavioral;
