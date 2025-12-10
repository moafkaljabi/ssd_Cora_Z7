----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2025 06:21:14 PM
-- Design Name: 
-- Module Name: seg7_tb - Behavioral
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


----------------------------------------------------------------------------------
-- Testbench for seg7 module adapted for Cora Z7 PMOD JB
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg7_tb is
end seg7_tb;

architecture sim of seg7_tb is

  -- Slow clock for simulation
  constant clk_hz     : integer := 100;
  constant clk_period : time    := 1 sec / clk_hz;

  signal clk   : std_logic := '1';
  signal rst   : std_logic := '1';
  signal value : integer range 0 to 99 := 0;

  -- The DUT now exposes only jb(7 downto 0)
  signal jb : std_logic_vector(7 downto 0);

begin

  ------------------------------------------------------------------------------
  -- Clock generation
  ------------------------------------------------------------------------------
  clk <= not clk after clk_period / 2;

  ------------------------------------------------------------------------------
  -- Device Under Test
  ------------------------------------------------------------------------------
  DUT : entity work.seg7(rtl)
    generic map (
      clk_cnt_bits => 4      -- smaller value for fast digit switching in sim
    )
    port map (
      clk   => clk,
      rst   => rst,
      value => value,
      jb    => jb
    );

  ------------------------------------------------------------------------------
  -- Stimulus / Sequencer
  ------------------------------------------------------------------------------
  SEQUENCER_PROC : process
  begin
    -- release reset after 2 cycles
    wait for clk_period * 2;
    rst <= '0';

    -- increment displayed value every second
    loop
      wait for 1 sec;

      if value = 99 then
        value <= 0;
      else
        value <= value + 1;
      end if;

    end loop;
  end process;

end architecture;
