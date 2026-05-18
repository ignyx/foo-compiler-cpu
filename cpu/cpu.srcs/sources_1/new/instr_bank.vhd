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
           clk, freeze : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (31 downto 0));
end instr_bank;

architecture Behavioral of instr_bank is
    constant CELL_COUNT: integer := 256;
    constant CELL_SIZE: integer := 32; -- bits
    subtype cell_t is std_logic_vector(CELL_SIZE - 1 downto 0);
    type memory_t is array (0 to CELL_COUNT - 1) of cell_t;
    
    signal memory: memory_t := (
    -- output from cross-assembler goes here
    x"06_00_00_00", -- AFC 0 0
    x"06_01_64_00", -- AFC 1 100
    x"08_00_01_00", -- STORE 0 1
    x"06_00_02_00", -- AFC 0 2
    x"06_01_fd_00", -- AFC 1 -3
    x"08_00_01_00", -- STORE 0 1
    x"06_01_02_00", -- AFC 1 2
    x"06_00_01_00", -- AFC 0 1
    x"07_01_01_00", -- LOAD 1 1
    x"08_00_01_00", -- STORE 0 1
    x"06_01_00_00", -- AFC 1 0
    x"07_01_01_00", -- LOAD 1 1
    x"09_00_01_00", -- PRI 0 1
    x"06_00_06_00", -- AFC 0 6
    x"06_01_05_00", -- AFC 1 5
    x"08_00_01_00", -- STORE 0 1
    x"06_00_07_00", -- AFC 0 7
    x"06_01_01_00", -- AFC 1 1
    x"08_00_01_00", -- STORE 0 1
    x"06_01_07_00", -- AFC 1 7
    x"06_00_07_00", -- AFC 0 7
    x"07_01_01_00", -- LOAD 1 1
    x"07_01_01_00", -- LOAD 1 1
    x"08_00_01_00", -- STORE 0 1
    x"06_01_06_00", -- AFC 1 6
    x"06_00_07_00", -- AFC 0 7
    x"07_01_01_00", -- LOAD 1 1
    x"07_00_00_00", -- LOAD 0 0
    x"08_01_00_00", -- STORE 1 0
    x"06_01_05_00", -- AFC 1 5
    x"07_01_01_00", -- LOAD 1 1
    x"09_00_01_00", -- PRI 0 1
    x"06_01_02_00", -- AFC 1 2
    x"07_01_01_00", -- LOAD 1 1
    x"09_00_01_00", -- PRI 0 1
    x"06_00_06_00", -- AFC 0 6
    x"06_01_ff_00", -- AFC 1 -1
    x"08_00_01_00", -- STORE 0 1
    x"06_01_02_00", -- AFC 1 2
    x"06_02_06_00", -- AFC 2 6
    x"07_01_01_00", -- LOAD 1 1
    x"07_02_02_00", -- LOAD 2 2
    x"06_03_06_00", -- AFC 3 6
    x"01_00_01_02", -- ADD 0 1 2
    x"08_03_00_00", -- STORE 3 0
    x"06_01_06_00", -- AFC 1 6
    x"06_00_02_00", -- AFC 0 2
    x"07_01_01_00", -- LOAD 1 1
    x"08_00_01_00", -- STORE 0 1
    x"06_01_02_00", -- AFC 1 2
    x"07_01_01_00", -- LOAD 1 1
    x"09_00_01_00", -- PRI 0 1
    x"06_00_06_00", -- AFC 0 6
    x"06_01_f6_00", -- AFC 1 -10
    x"08_00_01_00", -- STORE 0 1
    x"06_01_06_00", -- AFC 1 6
    x"06_00_03_00", -- AFC 0 3
    x"07_01_01_00", -- LOAD 1 1
    x"08_00_01_00", -- STORE 0 1
    x"06_01_02_00", -- AFC 1 2
    x"06_00_05_00", -- AFC 0 5
    x"07_01_01_00", -- LOAD 1 1
    x"08_00_01_00", -- STORE 0 1


     others => (others => '0'));
begin
    process begin
        -- NOTE: instr bank is synchronous because synchronous memory is easier to map on FPGA
        wait until rising_edge(clk);
        if freeze = '0' then
            data_out <= memory(to_integer(unsigned(addr)));
        end if;
    end process;
end Behavioral;
