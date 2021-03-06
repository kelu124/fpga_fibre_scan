library ieee;

use ieee.std_logic_1164.all;

entity p2s_dac is

port( 
    a,clk,clr: in std_logic;

    datain1:in std_logic_vector(15 downto 0);

    ld,s_data: out std_logic);

end p2s_dac;

architecture art of p2s_dac is
begin

process(a,clk,clr)

    variable I: integer;

begin

    if(clr='1') then
    
        I:=0;ld<='0';
    
    elsif( clk'event and clk='1') then
        
        if(a='1') then
        
            if(I=0) then
            
                I:=16; 
            
                s_data<='0';
            
            else
            
                s_data<=datain1(I-1);
            
                I:=I-1;
                
                ld<='1';
            
            end if;
        
        else 
            
            ld<='0';
        
        end if;
    
    end if; 

end process ;

end art;