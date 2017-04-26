Copyright (c) 2005-2009 Salvador E. Tropea <salvador en inti gov ar>
Copyright (c) 2005-2009 Instituto Nacional de Tecnología Industrial

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 2.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 02111-1307, USA

  This core is a helper used to write testbenches for cores connected to
Wishbone.
  The core replaces the WISHBONE master using a component that's controlled
by the testbench.
  Usage examples can be found in the testbenches of I2C and SIC packages.
Another example is testbench/wb_dummy_tb.vhdl, it verifies a simple core called
wb_dummy.vhdl. Additionaly, wb_dummy.vhdl can be used in WISHBONE master tests.
  If you use ghdl and you want to create a library just run make.

  We provide two mechanism:

Mechanism 1:
============

Instantiation example:
   -- Testbench side
   signal addr        : std_logic_vector(8-1 downto 0);
   signal datai       : std_logic_vector(8-1 downto 0);
   signal datao       : std_logic_vector(8-1 downto 0);
   signal rd          : std_logic:='0';
   signal wr          : std_logic:='0';
   signal rde         : std_logic;
   signal wre         : std_logic;
   -- WISHBONE side
   signal wb_rst      : std_logic:='1';
   signal wb_clk      : std_logic;--:='0';
   signal wb_adr      : std_logic_vector(8-1 downto 0);
   signal wb_dati     : std_logic_vector(8-1 downto 0):=(others => 'Z');
   signal wb_dato     : std_logic_vector(8-1 downto 0);
   signal wb_we       : std_logic;
   signal wb_stb      : std_logic;
   signal wb_cyc      : std_logic;
   signal wb_ack      : std_logic:='0';
   
   -- WISHBONE master simulator
   wb_master: WBHandler
      port map(
         addr_i => addr, data_i => datai, data_o => datao,
         rd_i => rd, wr_i => wr, rde_o => rde, wre_o => wre,
         wb_rst_i => wb_rst, wb_clk_i => wb_clk,  wb_ack_i => wb_ack,
         wb_adr_o => wb_adr, wb_dat_i => wb_dati, wb_dat_o => wb_dato,
         wb_we_o  => wb_we,  wb_stb_o => wb_stb,  wb_cyc_o => wb_cyc);

Simulating a read:
      WBRead(addr,SIC_FLGR,rd,rde);
      assert datao="00000000" and irq='0'
        report "Pending interrupts?!" severity failure;
 In this example datao is the result of reading SIC_FLGR address.

Simulating a write:
      WBWrite(addr,SIC_ENAR,datai,"00000001",wr,wre);
 In this example we are writing "00000001" to the SIC_ENAR address.


Mechanism 2:
============

 In this case we doesn't simulate any delay. Two signals must be created to
interface with the functions:

   signal wbi         : wb_bus_i_type;
   signal wbo         : wb_bus_o_type;

 They are connected to the WISHBONE like this:

   -- Connect the records to the individual signals
   wbi.clk  <= wb_clk;
   wbi.rst  <= wb_rst;
   wbi.dato <= wb_dato;
   wbi.ack  <= wb_ack;

   wb_stb   <= wbo.stb;
   wb_we    <= wbo.we;
   wb_adr   <= wbo.adr;
   wb_dati  <= wbo.dati;

 Finally we can read using:

      WBRead(REGISTER,wbi,wbo);
      assert wb_dato=x"03" report ...

 And write using:

      WBWrite(REGISTER,VALUE,wbi,wbo);

 WBRead waits for the rising edge of the clock after the operation. It allows
the read of wb_dato just before the call. It can be disabled using:

      WBRead(REGISTER,wbi,wbo,false);

 WBWrite doesn't wait, but if you need to wait use:

      WBWrite(REGISTER,VALUE,wbi,wbo,true);

