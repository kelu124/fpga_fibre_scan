--*****************************************************************************
--  @Copyright  All rights reserved.                    
--  Module name : adc_conf
--  Call by     : 
--  Description : Configuration for AD9518-3, read datasheet for reference
--  IC          : 
--  Version     : A
--  Note:       : 
--
--  Author      : Weibao Qiu
--  Date        : 2010.08
--  Update      : 
--                 
--*****************************************************************************
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity pll_conf is
port
(
     I_clk              : in    std_logic;
     I_reset_n          : in    std_logic; 
     
     O_ADC_ready        : out   std_logic;                                 
     O_FPGA_ADC_d       : out   std_logic; 
     O_FPGA_ADC_clk     : out   std_logic;  
     O_FPGA_ADC_en      : out   std_logic;
     O_FPGA_ADC_reset   : out   std_logic 
);
end pll_conf;

architecture rtl of pll_conf is

component pll_intf is
port
(
     I_clk              : in    std_logic;
     I_reset_n          : in    std_logic; 
     I_ADC_data         : in    std_logic_vector(23 downto 0);  
     O_ADC_ready        : out   std_logic;                                 
     I_ADC_trig         : in    std_logic;                     
     
     O_FPGA_ADC_d       : out   std_logic; 
     O_FPGA_ADC_clk     : out   std_logic;  
     O_FPGA_ADC_en      : out   std_logic;
     O_FPGA_ADC_reset   : out   std_logic 
);
end component pll_intf;

signal S_ADC_trig        : std_logic;
signal S_adc_cnt         : std_logic_vector(4 downto 0);

signal S_ADC_data        : std_logic_vector(23 downto 0);

signal S_ADC_ready       : std_logic;  
signal S_ADC_ready_1buf  : std_logic;
signal S_ADC_ready_2buf  : std_logic;
signal S_ADC_ready_3buf  : std_logic;
signal S_ADC_ready_4buf  : std_logic;

signal S_data_start      : std_logic;  
signal S_data_finish     : std_logic;

signal s_delay_cn        : std_logic_vector(31 downto 0);
signal s_delay_symbol    : std_logic;

constant C_DATA_NUMBER : std_logic_vector := "10111";   --The total number of data to be setted, plus 1 is the actual amount because of 0 start

constant C_N0 : std_logic_vector := "00000";
constant C_N1 : std_logic_vector := "00001";
constant C_N2 : std_logic_vector := "00010";
constant C_N3 : std_logic_vector := "00011";
constant C_N4 : std_logic_vector := "00100";
constant C_N5 : std_logic_vector := "00101";
constant C_N6 : std_logic_vector := "00110";
constant C_N7 : std_logic_vector := "00111";
constant C_N8 : std_logic_vector := "01000";
constant C_N9 : std_logic_vector := "01001";
constant C_N10 : std_logic_vector := "01010";
constant C_N11 : std_logic_vector := "01011";
constant C_N12 : std_logic_vector := "01100";
constant C_N13 : std_logic_vector := "01101";
constant C_N14 : std_logic_vector := "01110";
constant C_N15 : std_logic_vector := "01111";
constant C_N16 : std_logic_vector := "10000";
constant C_N17 : std_logic_vector := "10001";      
constant C_N18 : std_logic_vector := "10010";
constant C_N19 : std_logic_vector := "10011";             
constant C_N20 : std_logic_vector := "10100";
constant C_N21 : std_logic_vector := "10101"; 
constant C_N22 : std_logic_vector := "10110";
constant C_N23 : std_logic_vector := "10111";
constant C_N24 : std_logic_vector := "11000";

begin        

O_ADC_ready <= S_ADC_ready;

U0 : pll_intf
port map
(
     I_clk              =>   I_clk            ,
     I_reset_n          =>   I_reset_n        ,
     I_ADC_data         =>   S_ADC_data       ,
     O_ADC_ready        =>   S_ADC_ready      ,                  
     I_ADC_trig         =>   S_ADC_trig       ,       
                                              
     O_FPGA_ADC_d       =>   O_FPGA_ADC_d     , 
     O_FPGA_ADC_clk     =>   O_FPGA_ADC_clk   ,
     O_FPGA_ADC_en      =>   O_FPGA_ADC_en    ,
     O_FPGA_ADC_reset   =>   O_FPGA_ADC_reset 
);
-------------------
--prepare the sending data
-------------------
process(I_reset_n,I_clk)
begin
    if(I_reset_n = '0')then       
        S_ADC_data <= (others => '0');  
        S_ADC_trig <= '0';
    elsif(I_clk'event and I_clk = '1')then
        if(S_data_start = '1') and (S_data_finish = '0') then
            S_ADC_trig <= '1';
            case  S_adc_cnt  is
                when C_N0 =>
                    S_ADC_data <= "0000" & x"000" & "10111101";      --reg 0x000 Serial port configuration   
                
                --Soft reset, delay
                
                when C_N1 =>
                    S_ADC_data <= "0000" & x"000" & "10011001";
                                            
                when C_N2 =>
                    S_ADC_data <= "0000" & x"010" & "01111100";      --PLL normal                    
                    
                when C_N3 =>                                                                                 
                    S_ADC_data <= "0000" & x"018" & "00000111";      --reg 0x018, calibration set 
                    
                when C_N4 =>
                    S_ADC_data <= "0000" & x"011" & "00000001";      --reg 0x011 14-bit R divider, Bits[7:0] (LSB)
                when C_N5 =>
                    S_ADC_data <= "0000" & x"014" & "00011110";      --reg 0x014 B counter Bits[7:0] (LSB)  
                    --S_ADC_data <= "0000" & x"014" & "00101101";                   
                when C_N6 =>
                    S_ADC_data <= "0000" & x"016" & "00000100";      --reg 0x016 PLL Control 1, DM mode, divide by 8
                    --S_ADC_data <= "0000" & x"016" & "00000011"; 
                when C_N7 =>
                    S_ADC_data <= "0000" & x"017" & "10011100";      --set STATUS to monitor the REF1 state, good output high, HL2 light
            
                when C_N8 =>                                   
                    S_ADC_data <= "0000" & x"01C" & "00000010";      --ref1 power on
                     
                when C_N9 =>                                                                 
--                    S_ADC_data <= "0000" & x"0F0" & "00000011";      --reg 0x0F1 output 0, off
                    S_ADC_data <= "0000" & x"0F0" & "00001100";      --reg 0x0F1 output 0, on   
                when C_N10 =>                                                                 
                    S_ADC_data <= "0000" & x"0F1" & "00000011";      --reg 0x0F1 output 1, off                
                when C_N11 =>
--                    S_ADC_data <= "0000" & x"0F2" & "00000011";      --reg 0x0F2 output 2, off
                    S_ADC_data <= "0000" & x"0F2" & "00001100";      --reg 0x0F2 output 2, on
                when C_N12 =>                                                                
                    S_ADC_data <= "0000" & x"0F3" & "00000011";      --reg 0x0F3 output 3, off                
                when C_N13 =>                                                                
                    S_ADC_data <= "0000" & x"0F4" & "00001100";      --reg 0x0F4 output 4, on                
                when C_N14 =>                                                                
                    S_ADC_data <= "0000" & x"0F5" & "00000011";      --reg 0x0F5 output 5, off

                when C_N15 =>                                                              
                    S_ADC_data <= "0000" & x"191" & "00000000";    --reg 0x191 OUTPUT0 use divider, 0+0+2
                    --S_ADC_data <= "0000" & x"191" & "10000000";               -- Bypass divider    --for 600MHz output
                    
                when C_N16 =>                                   
                    S_ADC_data <= "0000" & x"193" & "00000000";    --reg 0x193 OUTPUT1 divide by 2, 0+0+2
                    --S_ADC_data <= "0000" & x"194" & "10000000";      --194 bypass divider,                               
                
                    
                when C_N17 =>                                                                
                    S_ADC_data <= "0000" & x"1E0" & "00000011";      --reg 0x1E0, divide by 5 
                    --S_ADC_data <= "0000" & x"1E0" & "00000001";   
                    
                when C_N18 =>                                                       
                    S_ADC_data <= "0000" & x"1E1" & "00000010";      --Internal PLL  
                    --S_ADC_data <= "0000" & x"1E1" & "00000001";        --External clk   
                
                when C_N19 =>                                                                
                    S_ADC_data <= "0000" & x"232" & "00000001";      --reg 0x232, Set 1 to active all register
                
                when C_N20 =>                                                                                  
                    S_ADC_data <= "0000" & x"018" & "00000110";      --reg 0x018                                                                                                                                           
                when C_N21 =>                                                                                  
                    S_ADC_data <= "0000" & x"232" & "00000001";      --reg 0x232, Set 1 to active all register
                
                --Wait for calibration, delay
                                                                                                              
                when C_N22 =>                                                                                 
                    S_ADC_data <= "0000" & x"018" & "00000111";      --reg 0x018                                                                                                                                
                when C_N23 =>                                                                                 
                    S_ADC_data <= "0000" & x"232" & "00000001";      --reg 0x232, Set 1 to active all register
              
                --Wait for calibration finish, delay
                
                when C_N24 =>                                                                
                    S_ADC_data <= "1000" & x"01F" & "00000100"; 
                
                when others =>
                    S_ADC_data <= (others => '0'); 
                end case;                                                
        else 
            S_ADC_data <= (others => '0');  
            S_ADC_trig <= '0';
        end if;
        
    end if;
end process;
--------------------------------------------------------------------------------------------------
--Control the start of sending data and the delay
--------------------------------------------------------------------------------------------------
process(I_reset_n,I_clk)
begin
    if(I_reset_n = '0')then
        S_ADC_ready_1buf <= '0';
        S_ADC_ready_2buf <= '0';
        S_ADC_ready_3buf <= '0';
        S_ADC_ready_4buf <= '0';
        S_adc_cnt <= (others => '1');
        S_data_start <= '0';
        S_data_finish <= '0';        
        s_delay_cn <= (others => '0');
        s_delay_symbol <= '0';
    elsif(I_clk'event and I_clk = '1')then                    
        if (S_data_finish = '0') then 
            s_delay_cn <= s_delay_cn + '1';
            
            S_ADC_ready_4buf <= S_ADC_ready_3buf;
            S_ADC_ready_3buf <= S_ADC_ready_2buf;
            S_ADC_ready_2buf <= S_ADC_ready_1buf;
            S_ADC_ready_1buf <= S_ADC_ready;
            if(S_ADC_ready_2buf = '0')and (S_ADC_ready_1buf = '1')then        --rising edge0                
                if (S_adc_cnt = C_DATA_NUMBER)then  --Count the number of data to be sent
                    S_data_finish <= '1';
                    S_adc_cnt <= (others => '0');
                elsif(S_adc_cnt = C_N0 or S_adc_cnt = C_N21 or S_adc_cnt = C_N23)then           --There is a delay after this value, set 4 means 5 data are sent  
                    s_delay_cn <= (others => '0');
                    s_delay_symbol <= '1';
                else 
                    S_data_finish <= '0';
                    S_data_start <= '1';
                    S_adc_cnt <= S_adc_cnt + '1';
                end if;
            elsif(S_ADC_ready_4buf = '0')and (S_ADC_ready_3buf = '1')then    
                S_data_start <= '0';
            elsif(s_delay_symbol = '1' and s_delay_cn = 500000)then         --Delay 10ms to wait proper setting
                S_data_start <= '1';
                s_delay_symbol <= '0';
                S_adc_cnt <= S_adc_cnt + '1';
            elsif(S_data_start = '1' and s_delay_cn = 500002)then           --Two cycles for start 
                S_data_start <= '0';
            end if;                    
        else
            S_ADC_ready_1buf <= '0';
            S_ADC_ready_2buf <= '0';
            S_ADC_ready_3buf <= '0';
            S_ADC_ready_4buf <= '0';
            S_adc_cnt <= (others => '0');
        end if;    
    end if;
end process;

end rtl;