----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.07.2026 20:15:07
-- Design Name: 
-- Module Name: prueba1 - arc_prueba1
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity prueba1 is
    Port ( 
           Entrada_Switch : in  STD_LOGIC; -- Viene del switch en el protoboard
           Entrada_Boton  : in  STD_LOGIC; -- Viene del pulsador en el protoboard
           Salida_Laser   : out STD_LOGIC  -- Va hacia la resistencia del transistor
         );
end prueba1;

architecture arc_prueba1 of prueba1 is
begin
    -- El láser se enciende solo cuando el switch habilita Y el botón se presiona
    Salida_Laser <= Entrada_Switch AND Entrada_Boton;
end arc_prueba1;
