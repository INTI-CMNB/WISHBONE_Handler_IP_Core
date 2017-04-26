------------------------------------------------------------------------------
----                                                                      ----
----  Wishbone Handler                                                    ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  That's a module used to easily write testbenches that uses          ----
---- Wishbone modules.                                                    ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador en inti gov ar                     ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2005 Salvador E. Tropea <salvador en inti gov ar>      ----
---- Copyright (c) 2005 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      WBHandler(Simulator) (Entity and architecture)     ----
---- File name:        wb_handler.vhdl                                    ----
---- Note:             None                                               ----
---- Limitations:      The code have 2 ns delays.                         ----
---- Errors:           None known                                         ----
---- Library:          wb_handler                                         ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      Spartan II (XC2S100-5-PQ208)                       ----
---- Language:         VHDL                                               ----
---- Wishbone:         MASTER (rev B.3)                                   ----
---- Synthesis tools:  Xilinx Release 6.2.03i - xst G.31a                 ----
---- Simulation tools: GHDL [Sokcho edition] (0.1x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity WBHandler is
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
end entity WBHandler;

architecture Simulator of WBHandler is
begin
   write_p:
   process
   begin
      wait until rd_i'event or wr_i'event or wb_clk_i'event;
      if wb_rst_i='1' then
         wb_adr_o <= (others => '0');
         wb_dat_o <= (others => 'Z');
         wb_we_o  <= '0';
         wb_stb_o <= '0';
         wb_cyc_o <= '0';
         data_o   <= (others => 'Z');
         rde_o    <= '0';
         wre_o    <= '0';
      else
         if rising_edge(wr_i) then
            -- Make sure the last transaction ended
            -- if ack_i='1' then
            --    wait until ack_i='0';
            -- end if;
            -- Write
            wb_adr_o <= addr_i;
            wb_dat_o <= data_i;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';
            -- Wait for clock
            wait until rising_edge(wb_clk_i);
            wait for 1 ns;
            -- Wait for ack
            if wb_ack_i='0' then
               wait until wb_ack_i='1';
            end if;
            wait for 1 ns;
            -- End of write
            wb_adr_o <= (others => '0');
            wb_dat_o <= (others => 'Z');
            wb_cyc_o <= '0';
            wb_stb_o <= '0';
            wb_we_o  <= '0';
            -- Tell it to our client
            wre_o  <= '1';
         else
            wre_o  <= '0';
         end if;
         if rising_edge(rd_i) then
            -- Make sure the last transaction ended
            -- if ack_i='1' then
            --    wait until ack_i='0';
            -- end if;
            -- Read
            wb_adr_o <= addr_i;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            -- Wait for clock
            wait until rising_edge(wb_clk_i);
            wait for 1 ns;
            -- Wait for ack
            if wb_ack_i='0' then
               wait until wb_ack_i='1';
            end if;
            wait for 1 ns;
            -- End of read
            wb_adr_o <= (others => '0');
            data_o   <= wb_dat_i;
            wb_cyc_o <= '0';
            wb_stb_o <= '0';
            wb_we_o  <= '0';
            -- Tell it to our client
            rde_o <= '1';
         else
            rde_o <= '0';
         end if;
      end if;
   end process write_p;
end architecture Simulator; -- of entity WBHandler
