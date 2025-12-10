----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2025 06:20:52 PM
-- Design Name: 
-- Module Name: seg7 - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg7 is
  generic (
    -- refresh_hz = (2 ** clk_cnt_bits) / clk_hz
    clk_cnt_bits : integer
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    value : in integer range 0 to 99;
    segments : out std_logic_vector(6 downto 0);
    digit_sel : out std_logic
  );
end seg7;

architecture rtl of seg7 is

  -- Binary-coded decimal representation of value
  subtype digit_type is integer range 0 to 9;
  type digits_type is array (1 downto 0) of digit_type;

  signal digits : digits_type;
  signal digit : digit_type;
  

  -- Clock cycle counter for alternating between digits
  signal clk_cnt : unsigned(clk_cnt_bits - 1 downto 0) := (others => '0');

  -- Internal signal to read from
  signal digit_sel_r : std_logic;


begin

  -- Drive the out port from the internal signal
  digit_sel <= digit_sel_r;


  --------------------------------------------------------------------
  -- Synchronous refresh counter
  --------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        clk_cnt <= (others => '0');
        digit_sel_r <= '0';  -- reset value
      else
        clk_cnt <= clk_cnt + 1;
        digit_sel_r <= clk_cnt(clk_cnt'high);  -- use internal signal
      end if;
    end if;
  end process;

  --------------------------------------------------------------------
  -- BCD Conversion (combinational)
  --------------------------------------------------------------------
  digits(1) <= value / 10;
  digits(0) <= value mod 10;

  --------------------------------------------------------------------
  -- Digit multiplexing logic (combinational)
  --------------------------------------------------------------------
  digit <= digits(0) when digit_sel_r = '0' else digits(1);


  ENCODER_PROC : process(digit)
  begin
    case digit is

      when 0 => segments <= "0111111";
      when 1 => segments <= "0000110";
      when 2 => segments <= "1011011";
      when 3 => segments <= "1001111";
      when 4 => segments <= "1100110";
      when 5 => segments <= "1101101";
      when 6 => segments <= "1111101";
      when 7 => segments <= "0000111";
      when 8 => segments <= "1111111";
      when 9 => segments <= "1101111";
      when others => segments <= "0000000";
    
    end case;
  end process;      
    

end architecture;