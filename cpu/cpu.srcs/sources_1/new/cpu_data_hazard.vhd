----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/11/2026 01:18:27 PM
-- Design Name: 
-- Module Name: cpu_data_hazard - Behavioral
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

entity cpu_data_hazard is
    Port ( clk, reset : in STD_LOGIC;
           OP_DI, A_DI, C_LI, B_LI : in STD_LOGIC_VECTOR (3 downto 0);
           Freeze_LI_CLOCK : out STD_LOGIC);
end cpu_data_hazard;

architecture Behavioral of cpu_data_hazard is
    -- The destination register is always A.
    -- We save the 3 previous destination registers and whether they were used (NOP).
    -- Index 0 contains the current instruction. So 4 total.
    constant HIST_SIZE : integer := 4;
    type memory_t is array (0 to HIST_SIZE - 1) of std_logic_vector(3 downto 0);
    signal used_reg : memory_t;
    -- Whether the register was used (not the case for NOP)
    signal used : std_logic_vector (HIST_SIZE - 1 downto 0);
    signal B_hazard, C_hazard : std_logic;
    signal B_reused, C_reused : std_logic;
    
    -- TODO similarly handle memory data hazards
begin
    process
    begin
        wait until falling_edge(clk);
        if (reset = '0') then
            used_reg <= (others => (others => '0'));
            used <= (others => '0');
        else
          -- rotate history
          for i in HIST_SIZE - 1 downto 1 loop
            used_reg(i) <= used_reg(i - 1);
          end loop;
          used_reg(0) <= A_DI;
          used(HIST_SIZE - 1 downto 1) <= used(HIST_SIZE - 2 downto 0);
          if OP_DI = x"0" then
            used(0) <= '0';
          else
            used(0) <= '1';
          end if;
        end if;
    end process;
    
    -- Could be refactored to use HIST_SIZE
    -- See https://stackoverflow.com/questions/23639586/implementing-an-or-gate-with-for-generate
    B_reused <= '1' when 
        (used(0) = '1' and B_LI = used_reg(0)) or 
        (used(1) = '1' and B_LI = used_reg(1)) or
        (used(2) = '1' and B_LI = used_reg(2)) or
        (used(3) = '1' and B_LI = used_reg(3)) else '0';
    C_reused <= '1' when 
        (used(0) = '1' and C_LI = used_reg(0)) or 
        (used(1) = '1' and C_LI = used_reg(1)) or
        (used(2) = '1' and C_LI = used_reg(2)) or
        (used(3) = '1' and C_LI = used_reg(3)) else '0';
    
    B_hazard <= '1' when B_reused = '1' and (OP_DI /= x"6" and OP_DI /= x"0") else '0'; -- AFC, NOP
    C_hazard <= '1' when C_reused = '1' and (OP_DI = x"1" or OP_DI = x"2" or OP_DI = x"3") else '0'; -- ADD, SUB, MUL
    
    Freeze_LI_CLOCK <= B_hazard or C_hazard;
end Behavioral;
