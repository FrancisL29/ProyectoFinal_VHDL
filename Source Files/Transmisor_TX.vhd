library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transmisor_tx is
    Port (
        reloj_tx_2hz  : in  STD_LOGIC;
        btn_start     : in  STD_LOGIC;
        btn_stop      : in  STD_LOGIC;
        sel_menu      : in  STD_LOGIC_VECTOR (1 downto 0);
        data_in       : in  STD_LOGIC_VECTOR (5 downto 0);
        pin_laser     : out STD_LOGIC
    );
end transmisor_tx;

architecture arc_transmisor_tx of transmisor_tx is

    type estados_fsm is (REPOSO, PREPARAR_TRAMA, ENVIANDO, PAUSA, CALIBRACION, CONTINUO);
    signal estado_actual : estados_fsm := REPOSO;

    signal trama_tx       : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal bits_a_enviar  : integer range 0 to 18 := 0;
    signal contador_bits  : integer range 0 to 18 := 0;
    signal contador_pausa : integer range 0 to 3 := 0;

begin

    proceso_transmision: process(reloj_tx_2hz)
    begin
        if rising_edge(reloj_tx_2hz) then
            
            if btn_stop = '1' then
                estado_actual <= REPOSO;
                pin_laser     <= '0';
                contador_bits <= 0;
                contador_pausa<= 0;
            else
                case estado_actual is
                
                    ---------------------------------------------------
                    when REPOSO =>
                        pin_laser     <= '0';
                        contador_bits <= 0;
                        contador_pausa<= 0;
                        
                        if sel_menu = "01" then
                            estado_actual <= CONTINUO;
                        elsif sel_menu = "10" then
                            estado_actual <= CALIBRACION;
                        elsif btn_start = '1' then
                            estado_actual <= PREPARAR_TRAMA;
                        end if;

                    ---------------------------------------------------
                    when CONTINUO =>
                        if sel_menu /= "01" then estado_actual <= REPOSO; else pin_laser <= data_in(0); end if;

                    ---------------------------------------------------
                    when CALIBRACION =>
                        if sel_menu /= "10" then estado_actual <= REPOSO; else pin_laser <= '1'; end if;

                    ---------------------------------------------------
                    when PREPARAR_TRAMA =>
                        if sel_menu = "00" then 
                            trama_tx(7) <= '1'; 
                            trama_tx(6 downto 1) <= data_in;
                            trama_tx(0) <= '0'; 
                            bits_a_enviar <= 8;
                            estado_actual <= ENVIANDO;

                        elsif sel_menu = "11" then 
                            -- Modo Cerradura Óptica: Envía la llave de los switches una sola vez
                            trama_tx(7) <= '1'; 
                            trama_tx(6 downto 1) <= data_in;
                            trama_tx(0) <= '0'; 
                            bits_a_enviar <= 8;
                            estado_actual <= ENVIANDO;
                        else
                            estado_actual <= REPOSO;
                        end if;

                    ---------------------------------------------------
                    when ENVIANDO =>
                        if contador_bits < bits_a_enviar then
                            pin_laser <= trama_tx(bits_a_enviar - 1 - contador_bits);
                            contador_bits <= contador_bits + 1;
                        else
                            pin_laser <= '0';
                            contador_bits <= 0;
                            estado_actual <= PAUSA; -- Tiempo de guarda para limpiar el sensor
                        end if;

                    ---------------------------------------------------
                    when PAUSA =>
                        pin_laser <= '0'; 
                        
                        -- Espera 1 segundo para limpiar luz residual
                        if contador_pausa < 2 then
                            contador_pausa <= contador_pausa + 1;
                        else
                            contador_pausa <= 0;
                            -- Ahora tanto el Menú 1 como el Menú 4 envían una sola vez y se detienen
                            estado_actual <= REPOSO;
                        end if;

                end case;
            end if;
        end if;
    end process;

end arc_transmisor_tx;