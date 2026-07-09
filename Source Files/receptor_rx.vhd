library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity receptor_rx is
    Port (
        reloj_rx_2hz        : in  STD_LOGIC;
        btn_reset           : in  STD_LOGIC;
        btn_stop            : in  STD_LOGIC;
        pin_sensor          : in  STD_LOGIC;
        
        sel_menu            : in  STD_LOGIC_VECTOR (1 downto 0);
        data_in             : in  STD_LOGIC_VECTOR (5 downto 0); 
        
        dato_recibido       : out STD_LOGIC_VECTOR (15 downto 0);
        errores_totales     : out integer range 0 to 9999;
        alerta_interrupcion : out STD_LOGIC
    );
end receptor_rx;

architecture arc_receptor_rx of receptor_rx is

    type estados_rx is (ESPERA, RECIBIENDO, PROCESANDO);
    signal estado_actual : estados_rx := ESPERA;

    signal registro_desplazamiento : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal bits_recibidos          : integer range 0 to 16 := 0;
    signal bits_esperados          : integer range 0 to 16 := 0;
    
    signal contador_errores        : integer range 0 to 9999 := 0;
    signal contador_failsafe       : integer range 0 to 15 := 0;
    
    signal paquete_listo           : STD_LOGIC := '0';
    signal luz_detectada           : STD_LOGIC;

begin

    -- Corrección de hardware: Polaridad invertida del sensor
    luz_detectada <= not pin_sensor;

    proceso_recepcion: process(reloj_rx_2hz, btn_reset)
    begin
        if btn_reset = '1' then
            estado_actual           <= ESPERA;
            registro_desplazamiento <= (others => '0');
            dato_recibido           <= (others => '0');
            paquete_listo           <= '0';
            
        elsif rising_edge(reloj_rx_2hz) then
            
            if btn_stop = '1' then
                dato_recibido <= (others => '0');
                estado_actual <= ESPERA;
                bits_recibidos <= 0;
                paquete_listo <= '0'; 
            else
                case estado_actual is
                
                    when ESPERA =>
                        bits_recibidos  <= 0;
                        
                        if luz_detectada = '0' then
                            if contador_failsafe < 12 then
                                contador_failsafe <= contador_failsafe + 1;
                            else
                                alerta_interrupcion <= '1';
                                if sel_menu = "11" then
                                    dato_recibido <= (others => '0');
                                end if;
                            end if;
                        else
                            contador_failsafe <= 0;
                            alerta_interrupcion <= '0';
                            
                            -- Menú 1 y Menú 4 usan el candado para no sobrescribirse con ruido
                            if (sel_menu = "00" or sel_menu = "11") and paquete_listo = '0' then
                                bits_esperados <= 6;
                                estado_actual  <= RECIBIENDO;
                            end if;
                        end if;

                    when RECIBIENDO =>
                        if bits_recibidos < bits_esperados then
                            registro_desplazamiento <= registro_desplazamiento(14 downto 0) & luz_detectada;
                            bits_recibidos <= bits_recibidos + 1;
                        else
                            estado_actual <= PROCESANDO;
                        end if;

                    when PROCESANDO =>
                        if sel_menu = "00" then
                            dato_recibido(15 downto 6) <= (others => '0');
                            dato_recibido(5 downto 0)  <= registro_desplazamiento(5 downto 0);
                            paquete_listo <= '1'; 
                            
                        elsif sel_menu = "11" then
                            -- Usamos el bit 15 como bandera secreta para decirle a la pantalla que llegó una clave
                            dato_recibido(15) <= '1'; 
                            dato_recibido(14 downto 6) <= (others => '0');
                            dato_recibido(5 downto 0)  <= registro_desplazamiento(5 downto 0);
                            paquete_listo <= '1'; 
                        end if;
                        
                        estado_actual <= ESPERA;
                        
                end case;
            end if;
        end if;
    end process;
    
    errores_totales <= contador_errores;

end arc_receptor_rx;