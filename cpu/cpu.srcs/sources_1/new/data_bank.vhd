----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2026 02:22:54 PM
-- Design Name: 
-- Module Name: data_bank - Behavioral
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

entity data_bank is
    Port ( addr : in STD_LOGIC_VECTOR (7 downto 0);
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           rw : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
end data_bank;

architecture Behavioral of data_bank is
    constant CELL_COUNT: integer := 256;
    constant CELL_SIZE: integer := 8; -- bits
    subtype cell_t is std_logic_vector(CELL_SIZE - 1 downto 0);
    type memory_t is array (CELL_COUNT - 1 downto 0) of cell_t;
    
    signal memory: memory_t;
begin
    process begin
        wait until rising_edge(clk);
        if rst = '0' then
            memory <= (others => x"00");
        elsif rw = '1' then
            -- read
            data_out <= memory(to_integer(unsigned(addr)));
        else
            -- write
            memory(to_integer(unsigned(addr))) <= data_in;
        end if;
    end process;
end Behavioral;
