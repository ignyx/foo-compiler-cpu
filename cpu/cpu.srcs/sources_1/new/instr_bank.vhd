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
     x"05_0A_01_00",
     x"06_00_08_00", -- AFC r0 0x08
     x"06_04_10_00", -- AFC r4 0x10
     x"06_05_11_00", -- AFC r5 0x11
     x"06_06_12_00", -- AFC r6 0x12
     x"06_07_13_00", -- AFC r7 0x13
     x"00_00_00_00", -- NOP
     x"00_00_00_00", -- NOP
     x"00_00_00_00", -- NOP
     x"00_00_00_00", -- NOP
     x"00_00_00_00", -- NOP
     x"00_00_00_00", -- NOP
     x"01_01_00_00", -- ADD r1 r0 r0
     x"02_02_00_00", -- MUL r2 r0 r0
     x"03_03_00_00", -- SOU r3 r0 r0
     x"00_00_00_00", -- NOP
     x"00_00_00_00", -- NOP
     x"08_04_00_00", -- STORE [r4] r0
     x"08_05_01_00", -- STORE [r5] r1
     x"08_06_02_00", -- STORE [r6] r2
     x"08_07_03_00", -- STORE [r7] r3
     x"00_00_00_00", -- NOP
     x"00_00_00_00", -- NOP
     x"07_0A_04_00", -- LOAD r10 [r4]
     x"07_0B_05_00", -- LOAD r11 [r5]
     x"07_0C_06_00", -- LOAD r12 [r6]
     x"07_0D_07_00", -- LOAD r13 [r7]
     others => (others => '0'));
begin
    process begin
        wait until rising_edge(clk);
        data_out <= memory(to_integer(unsigned(addr)));
    end process;
end Behavioral;
