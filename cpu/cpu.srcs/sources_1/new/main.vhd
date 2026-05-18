----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2026 05:47:42 PM
-- Design Name: 
-- Module Name: main - Behavioral
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
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           Dout : out STD_LOGIC_VECTOR (7 downto 0));
end main;

architecture Behavioral of main is
  component processor is
      Port ( clk, reset : in STD_LOGIC;
          Dout: out std_logic_vector(7 downto 0));
  end component;
    
  -- clock is at 50 MHz
  -- 2**25 = 33,554,432
  -- 2**21 = 2,097,152
  -- Passing the MSB (for 25) to CK results in 1-2 Hz
  -- Passing the MSB (for 21) to CK results in about 24 Hz
   signal divider_count: std_logic_vector(20 downto 0) := (others => '0');
begin
  cpu_uut: processor port map (clk => divider_count(20), reset => rst, dout => dout);
  process
  begin
    wait until rising_edge(CLK);
    divider_count <= divider_count + 1;
  end process;

end Behavioral;