------------------------------------------------------------------------------
----                                                                      ----
----  WISHBONE dummy testbench                                            ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  A test for the dummy slave. It also shows how to use the handler.   ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador en inti gov ar                     ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2009 Salvador E. Tropea <salvador en inti gov ar>      ----
---- Copyright (c) 2009 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      WB_Dummy_TB(Simulator) (Entity and architecture)   ----
---- File name:        wb_dummy_tb.vhdl                                   ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          None                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   utils.stdio                                        ----
----                   wbhandler.WishboneTB                               ----
---- Target FPGA:      None                                               ----
---- Language:         VHDL                                               ----
---- Wishbone:         None                                               ----
---- Synthesis tools:  None                                               ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library utils;
use utils.stdio.all;
library wb_handler;
use wb_handler.WishboneTB.all;

entity WB_Dummy_TB is
end entity WB_Dummy_TB;

architecture Simulator of WB_Dummy_TB is
   constant CLKPERIOD : time:=40 ns;
   constant TEST_B1   : std_logic_vector(7 downto 0):="01010101";
   constant TEST_B2   : std_logic_vector(7 downto 0):="01100110";
   
   signal wb_rst   : std_logic:='1';
   signal wb_clk   : std_logic;
   signal wb_adr   : std_logic_vector(7 downto 0):=(others => '0');
   signal wb_dati  : std_logic_vector(7 downto 0):=(others => 'Z');
   signal wb_dato  : std_logic_vector(7 downto 0);
   signal wb_we    : std_logic;
   signal wb_stb   : std_logic;
   signal wb_cyc   : std_logic;
   signal wb_ack   : std_logic:='0';

   signal wbi      : wb_bus_i_type;
   signal wbo      : wb_bus_o_type;
   
   signal stop_clock : std_logic:='0';
begin
   -- Clock
   do_clk:
   process
   begin
      wb_clk <= '0';
      wait for CLKPERIOD/2;
      wb_clk <= '1';
      wait for CLKPERIOD/2;
      if stop_clock='1' then
         wait;
      end if;
   end process do_clk;

   -- Reset pulse
   do_rst:
   process
   begin
      wb_rst <= '1';
      wait until rising_edge(wb_clk);
      wb_rst <= '0' after CLKPERIOD/4;
      wait;
   end process do_rst;

   -- Connect the records to the individual signals
   wbi.clk  <= wb_clk;
   wbi.rst  <= wb_rst;
   wbi.dato <= wb_dato;
   wbi.ack  <= wb_ack;

   wb_stb   <= wbo.stb;
   wb_we    <= wbo.we;
   wb_adr   <= wbo.adr;
   wb_dati  <= wbo.dati;
   
   the_dummy : WB_Dummy 
      port map(--Wishbone signals
         wb_clk_i => wb_clk, wb_rst_i => wb_rst, wb_adr_i => wb_adr,
         wb_dat_i => wb_dati, wb_dat_o => wb_dato, wb_we_i => wb_we,
         wb_stb_i => wb_stb, wb_ack_o => wb_ack);
   
   do_test:
   process
   begin
      outwrite("* Dummy slave testbench");
      wait until wb_rst='0';
      
      outwrite(" - Testing register 1");
      WBWrite(x"00",TEST_B1,wbi,wbo);
      WBRead(x"00",wbi,wbo);
      assert wb_dato=TEST_B1 report "Reg 1 test 1" severity failure;
      WBWrite(x"00",TEST_B2,wbi,wbo);
      WBRead(x"00",wbi,wbo);
      assert wb_dato=TEST_B2 report "Reg 1 test 2" severity failure;
      
      outwrite(" - Testing register 2");
      WBWrite(x"01",TEST_B1,wbi,wbo);
      WBRead(x"01",wbi,wbo);
      assert wb_dato=not(TEST_B1) report "Reg 2 test 1" severity failure;
      WBWrite(x"01",TEST_B2,wbi,wbo);
      WBRead(x"01",wbi,wbo);
      assert wb_dato=not(TEST_B2) report "Reg 2 test 2" severity failure;
      
      outwrite(" - Testing register 3");
      WBWrite(x"02",TEST_B1,wbi,wbo);
      WBRead(x"02",wbi,wbo);
      assert wb_dato=(TEST_B1 xor x"55") report "Reg 3 test 1" severity failure;
      WBWrite(x"02",TEST_B2,wbi,wbo);
      WBRead(x"02",wbi,wbo);
      assert wb_dato=(TEST_B2 xor x"55") report "Reg 3 test 2" severity failure;
      
      outwrite("* End of test");
      stop_clock <= '1';
      wait;
  end process do_test;   
end architecture Simulator; -- Entity: WB_Dummy_TB