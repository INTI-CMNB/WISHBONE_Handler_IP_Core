------------------------------------------------------------------------------
----                                                                      ----
----  Wishbone Testbench Helper                                           ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  That's a module used to easily write testbenches that uses          ----
---- Wishbone modules. Package.                                           ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador en inti gov ar                     ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2005-2009 Salvador E. Tropea <salvador en inti gov ar> ----
---- Copyright (c) 2005-2009 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      WishboneTB (package and body)                      ----
---- File name:        wb_handler_pkg.vhdl                                ----
---- Note:             None                                               ----
---- Limitations:      Delays of 300 ns in helpers and 2 ns in component. ----
---- Errors:           None known                                         ----
---- Library:          wb_handler                                         ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      N/A                                                ----
---- Language:         VHDL                                               ----
---- Wishbone:         MASTER (rev B.3)                                   ----
---- Synthesis tools:  N/A                                                ----
---- Simulation tools: GHDL [Sokcho edition] (0.1x/0.2x)                  ----
----                   ISIM Release 8.2.02i - ISE Simulator Engine I.33   ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package WishboneTB is
   type wb_bus_i_type is record
      clk  : std_logic;
      rst  : std_logic;
      dato : std_logic_vector(7 downto 0);
      ack  : std_logic;
   end record;

   type wb_bus_o_type is record
      stb  : std_logic;
      we   : std_logic;
      adr  : std_logic_vector(7 downto 0);
      dati : std_logic_vector(7 downto 0);
   end record;

   component WBHandler is
      generic(
         ADDR_W     : integer:=8;
         DATA_W     : integer:=8);
      port(-- Simple port
         addr_i     : in  std_logic_vector(ADDR_W-1 downto 0);
         data_i     : in  std_logic_vector(DATA_W-1 downto 0);
         data_o     : out std_logic_vector(DATA_W-1 downto 0);
         rd_i       : in  std_logic;
         wr_i       : in  std_logic;
         rde_o      : out std_logic:='0';
         wre_o      : out std_logic:='0';
         -- Wishbone side
         wb_rst_i   : in  std_logic;
         wb_clk_i   : in  std_logic;
         wb_adr_o   : out std_logic_vector(ADDR_W-1 downto 0);
         wb_dat_i   : in  std_logic_vector(DATA_W-1 downto 0);
         wb_dat_o   : out std_logic_vector(DATA_W-1 downto 0);
         wb_we_o    : out std_logic;
         wb_stb_o   : out std_logic;
         wb_cyc_o   : out std_logic;
         wb_ack_i   : in  std_logic);
   end component WBHandler;

   component WB_Dummy is
      port(
         wb_clk_i        : in  std_logic;
         wb_rst_i        : in  std_logic;
         wb_adr_i        : in  std_logic_vector(7 downto 0);
         wb_dat_i        : in  std_logic_vector(7 downto 0);
         wb_dat_o        : out std_logic_vector(7 downto 0);
         wb_we_i         : in  std_logic;
         wb_stb_i        : in  std_logic;
         wb_ack_o        : out std_logic);
   end component WB_Dummy;

   -- Using WBHandler
   procedure WBWrite(signal   addr_o  : out std_logic_vector(7 downto 0);
                     constant ADDRV   :     std_logic_vector(7 downto 0);
                     signal   data_o  : out std_logic_vector(7 downto 0);
                     constant IDATAV  :     std_logic_vector(7 downto 0);
                     signal   wr_o    : out std_logic;
                     signal   wre_i   : in  std_logic);

   procedure WBRead(signal   addr_o  : out std_logic_vector(7 downto 0);
                    constant ADDRV   :     std_logic_vector(7 downto 0);
                    signal   rd_o    : out std_logic;
                    signal   rde_i   : in  std_logic);

   -- Without WBHandler
   procedure WBWrite(constant dir  :     std_logic_vector(7 downto 0);
                     constant v    :     std_logic_vector(7 downto 0);
                     signal wbi    : in  wb_bus_i_type;
                     signal wbo    : out wb_bus_o_type;
                     constant wclk :     boolean:=false);
   
   procedure WBRead(constant dir  :     std_logic_vector(7 downto 0);
                    signal wbi    : in  wb_bus_i_type;
                    signal wbo    : out wb_bus_o_type;
                    constant wclk :     boolean:=false);
end package WishboneTB;

package body WishboneTB is
   procedure WBWrite(signal   addr_o  : out std_logic_vector(7 downto 0);
                     constant ADDRV   :     std_logic_vector(7 downto 0);
                     signal   data_o  : out std_logic_vector(7 downto 0);
                     constant IDATAV  :     std_logic_vector(7 downto 0);
                     signal   wr_o    : out std_logic;
                     signal   wre_i   : in  std_logic) is
   begin
      addr_o <= ADDRV;
      data_o <= IDATAV;
      wr_o   <= '1';
      if wre_i='0' then
         wait until wre_i='1';
      end if;
      wr_o <= '0' after 100 ns;
      wait for 200 ns;
   end procedure WBWrite;
   
   procedure WBRead(signal   addr_o  : out std_logic_vector(7 downto 0);
                    constant ADDRV   :     std_logic_vector(7 downto 0);
                    signal   rd_o    : out std_logic;
                    signal   rde_i   : in  std_logic) is
   begin
      addr_o <= ADDRV;
      rd_o   <= '1';
      if rde_i='0' then
         wait until rde_i='1';
      end if;
      rd_o <= '0' after 100 ns;
      wait for 200 ns;
   end procedure WBRead;

   procedure WBWrite(constant dir  :     std_logic_vector(7 downto 0);
                     constant v    :     std_logic_vector(7 downto 0);
                     signal wbi    : in  wb_bus_i_type;
                     signal wbo    : out wb_bus_o_type;
                     constant wclk :     boolean:=false) is
   begin
      if wbi.rst='1' then
         wait until wbi.rst='0';
      end if;
      wbo.adr  <= dir;
      wbo.dati <= v;
      wbo.stb  <= '1';
      wbo.we   <= '1';
      wait for 1 fs; -- ISIM workaround
      wait until rising_edge(wbi.clk) and wbi.rst='0';
      if wbi.ack='0' then
         wait until rising_edge(wbi.clk) and (wbi.ack='1' or wbi.rst='1');
      end if;
      wbo.we   <= '0';
      wbo.stb  <= '0';
      if wclk then
         wait until rising_edge(wbi.clk) and wbi.rst='0';
      end if;
   end procedure WBWrite;

   procedure WBRead(constant dir  :     std_logic_vector(7 downto 0);
                    signal wbi    : in  wb_bus_i_type;
                    signal wbo    : out wb_bus_o_type;
                    constant wclk :     boolean:=false) is
   begin
      if wbi.rst='1' then
         wait until wbi.rst='0';
      end if;
      wbo.adr  <= dir;
      wbo.stb  <= '1';
      wait for 1 fs; -- ISIM workaround
      wait until rising_edge(wbi.clk) and wbi.rst='0';
      if wbi.ack='0' then
         wait until rising_edge(wbi.clk) and (wbi.ack='1' or wbi.rst='1');
      end if;
      wbo.stb  <= '0';
      if wclk then
         wait until rising_edge(wbi.clk) and wbi.rst='0';
      end if;
   end procedure WBRead;
end package body WishboneTB;

