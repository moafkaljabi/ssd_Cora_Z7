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
    rst : in std_logic;
    jb : out std_logic_vector(7 downto 0)
  );
end top_seg7;

architecture rtl of top_seg7 is

  constant CLK_FREQ : integer := 125_000_000;
  constant CE_1KHZ_RATE : integer := 1000;
  constant DIV_1KHZ_MAX  : integer := CLK_FREQ / CE_1KHZ_RATE;

  -- ~953 Hz muxing frequency in seg7
  constant CLK_CNT_BITS  : integer := 17;

  signal value : integer range 0 to 99 := 0;
  signal segments : std_logic_vector(6 downto 0);
  signal digit_sel : std_logic;

    -- Clock enable generator
  signal div_cnt     : unsigned(16 downto 0) := (others => '0');
  signal ce_1khz     : std_logic := '0';

  -- 1-second counter (counts 1000 CE pulses)
  signal sec_cnt : unsigned(9 downto 0) := (others => '0');

begin

  -- Instantiate the seg7 module
  SEG7_INST : entity work.seg7(rtl)
  generic map (
    clk_cnt_bits => CLK_CNT_BITS
  )
  port map (
    clk => clk,
    rst => rst,
    value => value,
    segments => segments,
    digit_sel => digit_sel
  );


  -- Counter to increment value every ~1 second
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then 
        div_cnt <= (others => '0');
        ce_1khz <= '0';
      else
        if to_integer(div_cnt) = (DIV_1KHZ_MAX - 1) then
          div_cnt <= (others => '0');
          ce_1khz <= '1';
        else
          div_cnt <= div_cnt + 1;
          ce_1khz <= '0';
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------
  -- 1-SECOND COUNTER USING CE_1KHZ (synchronous)
  --------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sec_cnt <= (others => '0');
        value   <= 0;
      else
        if ce_1khz = '1' then
          if sec_cnt = 999 then
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
      end if;
    end if;
  end process;
  -- Map outputs to PMOD JB pins (segments on jb[6:0], digit_sel on jb[7])
  jb(6 downto 0) <= segments;
  jb(7) <= digit_sel;


end architecture;