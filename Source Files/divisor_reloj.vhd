library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divisor_reloj is
    Port (
        reloj_25mhz : in  STD_LOGIC; -- Reloj de entrada (puedes usar el de 25MHz del VGA)
        reset       : in  STD_LOGIC; -- Reset del sistema
        clk_tx_rx   : out STD_LOGIC  -- Reloj lento de salida para las FSMs de TX y RX
    );
end divisor_reloj;

architecture arc_divisor_reloj of divisor_reloj is

    -- =========================================================================
    -- CÁLCULO DE CONSTANTES (Para entrada de 25 MHz)
    -- =========================================================================
    -- Para 20 Hz (Cada bit dura 50 ms): 25,000,000 / 20 = 1,250,000 ciclos totales.
    -- El semiconductor cambia de estado a la mitad del conteo: 1,250,000 / 2 = 625,000.
    constant LIMITE_20HZ : integer := 625000;
    
    -- Para 50 Hz (Cada bit dura 20 ms): 25,000,000 / 50 = 500,000 ciclos totales.
    -- El semiconductor cambia de estado a la mitad del conteo: 500,000 / 2 = 250,000.
    constant LIMITE_50HZ : integer := 250000;
    
    -- CONFIGURACIÓN: Elige aquí qué constante usar cambiando el valor asignado
    constant LIMITE_ACTUAL : integer := LIMITE_20HZ; -- Cambiar a LIMITE_50HZ si quieres más velocidad

    -- Contador interno
    signal contador       : integer range 0 to 1250000 := 0;
    signal reloj_lento_sg : STD_LOGIC := '0';

begin

    process(reloj_25mhz, reset)
    begin
        if reset = '1' then
            contador <= 0;
            reloj_lento_sg <= '0';
        elsif rising_edge(reloj_25mhz) then
            if contador >= (LIMITE_ACTUAL - 1) then
                contador <= 0;
                reloj_lento_sg <= not reloj_lento_sg; -- Invierte el estado para generar onda cuadrada
            else
                contador <= contador + 1;
            end if;
        end if;
    end process;

    -- Asignación de la señal de salida al puerto físico/lógico
    clk_tx_rx <= reloj_lento_sg;

end arc_divisor_reloj;
