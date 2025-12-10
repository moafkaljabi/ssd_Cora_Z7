----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/09/2025 01:58:53 AM
-- Design Name: 
-- Module Name: top_seg7 - Behavioral
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

entity top_seg7 is
  port (
    clk : in std_logic;
    jb : out std_logic_vector(7 downto 0)
  );
end top_seg7;

architecture rtl of top_seg7 is

  constant clk_hz : integer := 125_000_000;
  constant sec_period : integer := clk_hz;  -- 1 second interval
  constant clk_cnt_bits : integer := 17;    -- For ~953 Hz digit switch rate

  signal rst : std_logic := '0';  -- Tied low; add reset input if needed
  signal value : integer range 0 to 99 := 0;
  signal segments : std_logic_vector(6 downto 0);
  signal digit_sel : std_logic;

  signal sec_cnt : unsigned(26 downto 0) := (others => '0');

begin

  -- Instantiate the seg7 module
  SEG7_INST : entity work.seg7(rtl)
  generic map (
    clk_cnt_bits => clk_cnt_bits
  )
  port map (
    clk => clk,
    rst => rst,
    value => value,
    segments => segments,
    digit_sel => digit_sel
  );

  -- Map outputs to PMOD JB pins (assuming segments on jb[6:0], digit_sel on jb[7])
  jb(6 downto 0) <= segments;
  jb(7) <= digit_sel;

  -- Synthesizable counter to increment value every ~1 second
  COUNT_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if sec_cnt = sec_period - 1 then
        sec_cnt <= (others => '0');
        if value = 99 then
          value <= 0;
        else
          value <= value + 1;
        end if;
      else
        sec_cnt <= sec_cnt + 1;
      end if;
    end if;
  end process;

end architecture;