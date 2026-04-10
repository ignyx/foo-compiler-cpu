----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2026 01:46:30 PM
-- Design Name: 
-- Module Name: test_register_bank - Behavioral
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

entity test_register_bank is
--  Port ( );
end test_register_bank;

architecture Behavioral of test_register_bank is
    component register_bank is
    Port ( reg_a : in STD_LOGIC_VECTOR (3 downto 0);
           reg_b : in STD_LOGIC_VECTOR (3 downto 0);
           reg_w : in STD_LOGIC_VECTOR (3 downto 0);
           w : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           q_a : out STD_LOGIC_VECTOR (7 downto 0);
           q_b : out STD_LOGIC_VECTOR (7 downto 0));
    end component;

    signal Rst_test, w_test : std_logic;
    signal data_test, q_a_test, q_b_test : std_logic_vector(7 downto 0);
    signal reg_a_test, reg_b_test, reg_w_test : std_logic_vector(3 downto 0);
    
    signal Clock_test: std_logic := '0';
    constant Clock_period : time := 10 ns;

begin
    register_bank_uut: register_bank port map (
        reg_a => reg_a_test,
        reg_b => reg_b_test,
        reg_w => reg_w_test,
        w => w_test,
        data => data_test,
        rst => rst_test,
        clk => Clock_test,
        q_a => q_a_test,
        q_b => q_b_test
     );
     
     Clock_process : process
        begin
            Clock_test <= not(Clock_test);
            wait for Clock_period/2;
     end process;


    Rst_test <= '0', '1' after 40 ns;
    data_test <= x"50", x"15" after 200ns;
    w_test <= '1', '0' after 100 ns, '1' after 230ns;
    reg_w_test <= x"1", x"A" after 60ns, x"B" after 250ns;
    reg_a_test <= x"A";
    reg_b_test <= x"B";


end Behavioral;
