----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2026 02:31:14 PM
-- Design Name: 
-- Module Name: test_data_bank - Behavioral
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

entity test_data_bank is
--  Port ( );
end test_data_bank;

architecture Behavioral of test_data_bank is
    component data_bank is
    Port ( addr : in STD_LOGIC_VECTOR (7 downto 0);
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           rw : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    signal addr_test, data_in_test, data_out_test: std_logic_vector(7 downto 0);
    signal rw_test, rst_test: std_logic;
    
    signal Clock_test: std_logic := '0';
    constant Clock_period : time := 10 ns;
    
begin
    data_bank_uut: data_bank port map (
        addr => addr_test,
        data_in => data_in_test,
        rw => rw_test,
        rst => rst_test,
        clk => clock_test,
        data_out => data_out_test
    );
    
    Clock_process : process
    begin
        Clock_test <= not(Clock_test);
        wait for Clock_period/2;
     end process;


    Rst_test <= '0', '1' after 40 ns;
    data_in_test <= x"50", x"15" after 200ns;
    rw_test <= '1', '0' after 100 ns, '1' after 230ns;
    addr_test <= x"01", x"0A" after 60ns, x"0B" after 250ns;


end Behavioral;
