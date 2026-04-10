----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2026 03:14:31 PM
-- Design Name: 
-- Module Name: test_instr_bank - Behavioral
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

entity test_instr_bank is
--  Port ( );
end test_instr_bank;

architecture Behavioral of test_instr_bank is
    component instr_bank is
    Port ( addr : in STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    signal addr_test: std_logic_vector(7 downto 0);
    signal data_out_test: std_logic_vector(31 downto 0);
    
    signal Clock_test: std_logic := '0';
    constant Clock_period : time := 10 ns;
    
begin
    instr_bank_uut: instr_bank port map (
        addr => addr_test,
        clk => clock_test,
        data_out => data_out_test
    );
    
    Clock_process : process
    begin
        Clock_test <= not(Clock_test);
        wait for Clock_period/2;
     end process;

    addr_test <= x"00", x"01" after 60ns, x"02" after 100ns;


end Behavioral;
