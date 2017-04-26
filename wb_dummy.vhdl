------------------------------------------------------------------------------
----                                                                      ----
----  WISHBONE test dummy                                                 ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  This is a simple WISHBONE slave to be used in master testbenches.   ----
----  It implements 3 registers. The first is trasparent and has no       ----
----  wait-states, the second negates its value and has 1 ws and the      ----
----  third does a 0x55 xor and has 2 ws.                                 ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador en inti.gob.ar                     ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2009 Salvador E. Tropea <salvador en inti.gob.ar>      ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      WB_Dummy(Simulator) (Entity and architecture)      ----
---- File name:        wb_dummy.vhdl                                      ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          None                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      N/A                                                ----
---- Language:         VHDL                                               ----
---- Wishbone:         SLAVE (rev B.3)                                    ----
---- Synthesis tools:  N/A                                                ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
----                                                                      ----
---- Wishbone Datasheet                                                   ----
----                                                                      ----
----  1 Revision level                      B.3                           ----
----  2 Type of interface                   SLAVE                         ----
----  3 Defined signal names                RST_I => wb_rst_i             ----
----                                        CLK_I => wb_clk_i             ----
----                                        ADR_I => wb_adr_i             ----
----                                        DAT_I => wb_dat_i             ----
----                                        WE_I  => wb_we_i              ----
----                                        ACK_O => wb_ack_o             ----
----                                        STB_I => wb_stb_i             ----
----  4 ERR_I                               Unsupported                   ----
----  5 RTY_I                               Unsupported                   ----
----  6 TAGs                                None                          ----
----  7 Port size                           8-bit                         ----
----  8 Port granularity                    8-bit                         ----
----  9 Maximum operand size                8-bit                         ----
---- 10 Data transfer ordering              N/A                           ----
---- 11 Data transfer sequencing            Undefined                     ----
---- 12 Constraints on the CLK_I signal     None                          ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity WB_Dummy is
   port(
      wb_clk_i        : in  std_logic;
      wb_rst_i        : in  std_logic;
      wb_adr_i        : in  std_logic_vector(7 downto 0);
      wb_dat_i        : in  std_logic_vector(7 downto 0);
      wb_dat_o        : out std_logic_vector(7 downto 0);
      wb_we_i         : in  std_logic;
      wb_stb_i        : in  std_logic;
      wb_ack_o        : out std_logic);
end entity WB_Dummy;

architecture Simulator of WB_Dummy is
   signal v1_r      : std_logic_vector(7 downto 0);
   signal v2_r      : std_logic_vector(7 downto 0);
   signal v3_r      : std_logic_vector(7 downto 0);
   signal ack1      : std_logic;
   signal ack2_r    : std_logic;
   signal ack3      : std_logic;
   signal sel1      : std_logic;
   signal sel2      : std_logic;
   signal sel3      : std_logic;
   signal cnt3_r    : integer:=0;
begin
   wb_ack_o <= ack1 or ack2_r or ack3;
   wb_dat_o <= v1_r when sel1='1' else
               v2_r when sel2='1' and ack2_r='1' else
               v3_r when sel3='1' and ack3='1' else
               (others => 'Z');

   -----------------------------------
   -- Register 1 (trasparent, 0 ws) --
   -----------------------------------
   sel1 <= '1' when unsigned(wb_adr_i)=0 and wb_stb_i='1' else '0';
   do_r1:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            v1_r <= (others => '0');
         elsif sel1='1' and wb_we_i='1' then
            v1_r <= wb_dat_i;
         end if;
      end if;
   end process do_r1;
   ack1 <= sel1;

   --------------------------------
   -- Register 2 (negated, 1 ws) --
   --------------------------------
   sel2 <= '1' when unsigned(wb_adr_i)=1 and wb_stb_i='1' else '0';
   do_r2:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         ack2_r <= '0';
         if wb_rst_i='1' then
            v2_r   <= (others => '0');
         elsif sel2='1' then
            if ack2_r='1' then
               if wb_we_i='1' then
                  v2_r <= not(wb_dat_i);
               end if;
            else
               ack2_r <= '1';
            end if;
         end if;
      end if;
   end process do_r2;

   --------------------------------
   -- Register 3 (xor 0x55, 2 ws) --
   --------------------------------
   sel3 <= '1' when unsigned(wb_adr_i)=2 and wb_stb_i='1' else '0';
   do_r3:
   process (wb_clk_i)
      variable cnt : integer:=0;
   begin
      if rising_edge(wb_clk_i) then
         cnt3_r <= 0;
         if wb_rst_i='1' then
            v3_r <= (others => '0');
         elsif sel3='1' then
            if cnt3_r=2 then
               if wb_we_i='1' then
                  v3_r <= wb_dat_i xor x"55";
               end if;
            else
               cnt3_r <= cnt3_r+1;
            end if;
         end if;
      end if;
   end process do_r3;
   ack3 <= '1' when cnt3_r=2 else '0';
end architecture Simulator; -- Entity: WB_Dummy
