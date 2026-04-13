----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2026 02:49:13 PM
-- Design Name: 
-- Module Name: alu - Behavioral
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
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
  port(
    A, B: in std_logic_vector(7 downto 0);
    S: out std_logic_vector(7 downto 0);
    Ctrl_ALU: in std_logic_vector(2 downto 0);
    C, O, Z, N: out std_logic
  );
end alu;

architecture struct of alu is
  signal A_ext, B_ext, S_ext: std_logic_vector(15 downto 0);
begin
  A_ext <= x"00" & A;
  B_ext <= x"00" & B;
  process(A_ext,B_ext,Ctrl_ALU)
  begin
    if Ctrl_ALU="001" then S_ext <= A_ext + B_ext;
    elsif Ctrl_ALU="011" then S_ext <= A_ext - B_ext;
    elsif Ctrl_ALU="010" then S_ext <= A * B;
    -- these are unspecified
    elsif Ctrl_ALU="100" then S_ext <= A & B;
    elsif Ctrl_ALU="110" then S_ext <= A or B;
    elsif Ctrl_ALU="101" then S_ext <= A xor B;
    elsif Ctrl_ALU="111" then S_ext <= not A;
    end if;
  end process;
  -- downto is used on little-endian systems.
  -- 7th bit is MSB.
  -- NOTE: apparently endianness applies to bytes but not bits
  S <= S_ext(7 downto 0);
  C <= '1' when S_ext(15 downto 8) /= x"00" and Ctrl_ALU="001" else '0';
  O <= '1' when S_ext(15 downto 8) /= x"00" and Ctrl_ALU="010" else '0';
  N <= '1' when S_ext(15) = '1' else '0';
  Z <= '1' when S_ext(7 downto 0) = x"00" else '0';
end struct;
