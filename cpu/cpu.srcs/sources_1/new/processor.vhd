----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 12:41:15 PM
-- Design Name: 
-- Module Name: processor - Behavioral
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
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity processor is
Port ( clk, reset : in STD_LOGIC );
end processor;

architecture Behavioral of processor is
  signal ip : std_logic_vector(7 downto 0);

  component instr_bank is
    Port ( addr : in STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (31 downto 0));
  end component;
  
  signal tmp_data_out : std_logic_vector (31 downto 0);
  signal A_LIDI, B_LIDI, C_LIDI, OP_LIDI: std_logic_vector(7 downto 0);

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
  
  signal A_DIEX, B_DIEX, C_DIEX, OP_DIEX: std_logic_vector(7 downto 0);

  component alu
    port(
      A, B: in std_logic_vector(7 downto 0);
      S: out std_logic_vector(7 downto 0);
      Ctrl_ALU: in std_logic_vector(2 downto 0);
      C, O, Z, N: out std_logic
    );
  end component;
  
  signal A_EXMem, B_EXMem, OP_EXMem: std_logic_vector(7 downto 0);

  component data_bank is
    Port ( addr : in STD_LOGIC_VECTOR (7 downto 0);
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           rw : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
  end component;

  signal A_MemRE, B_MemRE, OP_MemRE: std_logic_vector(7 downto 0);
  signal write_back_MemRE: std_logic;

begin
    cpu_instr_bank: instr_bank port map (
        addr => ip,
        clk => clk,
        data_out => tmp_data_out
    );
    
    cpu_register_bank: register_bank port map (
        reg_a => B_LIDI(3 downto 0),
        reg_b => C_LIDI(3 downto 0),
        reg_w => A_MemRE(3 downto 0),
        w => write_back_MemRE,
        data => B_MemRE,
        rst => reset,
        clk => clk
        -- TODO out
    );
    
    write_back_MemRE <= '1' when OP_MemRE = x"06" else '0';
    
    process begin
        wait until rising_edge(clk);
        if (reset = '0') then
            ip <= (others => '0');
        else
        -- Sequentially update signals, starting with last stage
        A_MemRE <= A_EXMem;
        B_MemRE <= B_EXMem;
        OP_MemRE <= OP_EXMem;
        
        A_EXMem <= A_DIEX;
        B_EXMem <= B_DIEX;
        OP_EXMem <= OP_DIEX;
        
        A_DIEX <= A_LIDI;
        B_DIEX <= B_LIDI;
        OP_DIEX <= OP_LIDI;
        
        
        OP_LIDI <= tmp_data_out(31 downto 24);
        A_LIDI <= tmp_data_out(23 downto 16);
        B_LIDI <= tmp_data_out(15 downto 8);
        C_LIDI <= tmp_data_out(7 downto 0);
        
        ip <= ip + 1;
        
        end if;
    end process;
    
    -- TODO:
    -- use components
    -- use signal A_LIDI
    -- use a process to sync components on clock
    -- signal updates happen on clock
    

end Behavioral;
