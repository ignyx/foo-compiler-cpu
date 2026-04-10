----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2026 12:56:59 PM
-- Design Name: 
-- Module Name: register_bank - Behavioral
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
use IEEE.std_logic_unsigned.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_bank is
    Port ( reg_a : in STD_LOGIC_VECTOR (3 downto 0);
           reg_b : in STD_LOGIC_VECTOR (3 downto 0);
           reg_w : in STD_LOGIC_VECTOR (3 downto 0);
           w : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           q_a : out STD_LOGIC_VECTOR (7 downto 0);
           q_b : out STD_LOGIC_VECTOR (7 downto 0));
end register_bank;

architecture Behavioral of register_bank is
    constant REGISTER_COUNT: integer := 16;
    constant REGISTER_SIZE: integer := 8; -- bits
    subtype register_t is std_logic_vector(REGISTER_SIZE - 1 downto 0);
    type registers_t is array (REGISTER_COUNT - 1 downto 0) of register_t;

    signal memory: registers_t;
begin
    process begin
        wait until rising_edge(clk);
        if rst = '0' then
            memory <= (others => x"00");
        elsif w = '1' then
            memory(to_integer(unsigned(reg_w))) <= data;
        end if;
    end process;
    q_a <= memory(to_integer(unsigned(reg_a)));
    q_b <= memory(to_integer(unsigned(reg_b)));
end Behavioral;
