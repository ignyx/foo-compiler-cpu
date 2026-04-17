----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2026 02:53:41 PM
-- Design Name: 
-- Module Name: instr_bank - Behavioral
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

entity instr_bank is
    Port ( addr : in STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (31 downto 0));
end instr_bank;

architecture Behavioral of instr_bank is
    constant CELL_COUNT: integer := 256;
    constant CELL_SIZE: integer := 32; -- bits
    subtype cell_t is std_logic_vector(CELL_SIZE - 1 downto 0);
    type memory_t is array (0 to CELL_COUNT - 1) of cell_t;
    
    signal memory: memory_t := (
    -- output from cross-compiler goes here
     x"01_00_01_02",
     x"01_00_01_03",
     x"06_00_01_00",
     x"06_01_FF_03",
     x"06_00_04_03",
     x"06_00_05_03",
     others => (others => '0'));
begin
    process begin
        wait until rising_edge(clk);
        data_out <= memory(to_integer(unsigned(addr)));
    end process;
end Behavioral;
