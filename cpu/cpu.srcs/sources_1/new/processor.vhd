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
  -- Recognized instruction opcodes --
  subtype cpu_instr_t is std_logic_vector(3 downto 0);
  constant INSTR_NOP: cpu_instr_t := x"0";
  constant INSTR_ADD: cpu_instr_t := x"1";
  constant INSTR_MUL: cpu_instr_t := x"2";
  constant INSTR_SUB: cpu_instr_t := x"3";
  constant INSTR_DIV: cpu_instr_t := x"4";
  constant INSTR_COP: cpu_instr_t := x"5";
  constant INSTR_AFC: cpu_instr_t := x"6";
  constant INSTR_LOAD: cpu_instr_t := x"7";
  constant INSTR_STORE: cpu_instr_t := x"8";



  signal ip : std_logic_vector(7 downto 0);

  component instr_bank is
    Port ( addr : in STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (31 downto 0));
  end component;
  
  signal instr_bank_out : std_logic_vector (31 downto 0);
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
  signal register_q_a, register_q_b : std_logic_vector (7 downto 0);
  
  signal A_DIEX, B_DIEX, C_DIEX, OP_DIEX: std_logic_vector(7 downto 0);

  signal alu_op_DIEX: std_logic_vector(2 downto 0);
  component alu
    port(
      A, B: in std_logic_vector(7 downto 0);
      S: out std_logic_vector(7 downto 0);
      Ctrl_ALU: in std_logic_vector(2 downto 0);
      C, O, Z, N: out std_logic
    );
  end component;
  signal alu_out: std_logic_vector(7 downto 0);
  
  signal A_EXMem, B_EXMem, OP_EXMem: std_logic_vector(7 downto 0);

  signal data_bank_addr: std_logic_vector(7 downto 0);
  signal data_bank_rw: std_logic;
  component data_bank is
    Port ( addr : in STD_LOGIC_VECTOR (7 downto 0);
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           rw : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
  end component;
  signal data_bank_out: std_logic_vector(7 downto 0);

  signal A_MemRE, B_MemRE, OP_MemRE: std_logic_vector(7 downto 0);
  signal write_back_MemRE: std_logic;

begin
    cpu_instr_bank: instr_bank port map (
        addr => ip,
        clk => clk,
        data_out => instr_bank_out
    );
    
    cpu_register_bank: register_bank port map (
        reg_a => B_LIDI(3 downto 0),
        reg_b => C_LIDI(3 downto 0),
        reg_w => A_MemRE(3 downto 0),
        w => write_back_MemRE,
        data => B_MemRE,
        rst => reset,
        clk => clk,
        q_a => register_q_a,
        q_b => register_q_b
    );
    
    cpu_alu: alu port map (
        A => B_DIEX,
        B => C_DIEX,
        Ctrl_ALU => alu_op_DIEX,
        S => alu_out
    );
    -- only support NOP, ADD, MUL, SUB
    alu_op_DIEX(1 downto 0) <= OP_DIEX(1 downto 0) when OP_DIEX(7 downto 2) = x"0" else (others => '0');
    alu_op_DIEX(2) <= '0';
    
    data_bank_addr <= A_EXmem when OP_EXMem = INSTR_STORE else B_EXMem;
    data_bank_rw <= '0' when OP_EXMem = INSTR_STORE else '1';
    cpu_data_bank: data_bank port map (
        addr => data_bank_addr,
        data_in => B_EXMem,
        data_out => data_bank_out,
        rw => data_bank_rw,
        rst => reset,
        clk => clk
    );


    write_back_MemRE <= '1' when OP_MemRE /= INSTR_STORE and OP_MemRE /= INSTR_NOP else '0';
    
    process begin
        wait until rising_edge(clk);
        if (reset = '0') then
            ip <= (others => '0');
        else
        -- Sequentially update signals, starting with last stage
        A_MemRE <= A_EXMem;
        -- TODO perf: These if blocks could be simplified to signals
        -- TODO perf: also we could only check the nth last bits of instr. might already be the case?
        if (OP_EXMem = INSTR_LOAD) then
            B_MemRE <= data_bank_out;
        else
            B_MemRE <= B_EXMem;
        end if;
        OP_MemRE <= OP_EXMem;
        
        A_EXMem <= A_DIEX;
        -- use ALU output for opcodes 0x00 through 0x04, ie NOP, ADD, MUL, SOU
        if (OP_DIEX(7 downto 2) = x"0") then
            B_EXMem <= alu_out;
        else
            B_EXMem <= B_DIEX;
        end if;
        OP_EXMem <= OP_DIEX;
        
        A_DIEX <= A_LIDI;
        C_DIEX <= register_q_b;
        if (OP_LIDI = INSTR_AFC or OP_LIDI = INSTR_LOAD) then
            B_DIEX <= B_LIDI;
        else
            B_DIEX <= register_q_a; -- TODO check if mistake, was q_b here
        end if;
        -- B_DIEX <= B_LIDI when OP_LIDI = x"06" else register_q_b;
        OP_DIEX <= OP_LIDI;
        
        -- TODO ask why LOAD/STORE use an address from the code and not from a register ?? How does a loop work ?
        -- OK to use register
        
        OP_LIDI <= instr_bank_out(31 downto 24);
        A_LIDI <= instr_bank_out(23 downto 16);
        B_LIDI <= instr_bank_out(15 downto 8);
        C_LIDI <= instr_bank_out(7 downto 0);
        
        ip <= ip + 1;
        
        end if;
    end process;
end Behavioral;
