----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2026 03:00:05 PM
-- Design Name: 
-- Module Name: test_alu - Behavioral
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

entity test_alu is
end test_alu;

architecture bench of test_alu is
  component alu
    port(
      A, B: in std_logic_vector(7 downto 0);
      S: out std_logic_vector(7 downto 0);
      Ctrl_ALU: in std_logic_vector(2 downto 0);
      C, O, Z, N: out std_logic
    );
  end component;

  signal A, B, S: std_logic_vector(7 downto 0);
  signal Ctrl_ALU: std_logic_vector(2 downto 0);
  signal C, O, Z, N: std_logic;

  begin
    my_alu: alu port map (A, B, S, Ctrl_ALU, C, O, Z, N);
    A <= x"00", x"03" after 100 ns, x"ff" after 210ns, x"10" after 240ns;
    B <= x"01", x"05" after 150 ns, x"10" after 220ns, x"10" after 240ns;
    Ctrl_ALU <= "000", "001" after 20ns, "011" after 40 ns,"010" after 200ns, "001" after 210ns, "010" after 250ns;

    
end bench;
