library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlador_vga is
    Port (
        reloj_vga_25mhz     : in  STD_LOGIC;
        sel_menu            : in  STD_LOGIC_VECTOR (1 downto 0);
        data_in             : in  STD_LOGIC_VECTOR (5 downto 0);
        dato_recibido       : in  STD_LOGIC_VECTOR (15 downto 0);
        pin_sensor          : in  STD_LOGIC;
        errores_totales     : in  integer range 0 to 9999;
        alerta_interrupcion : in  STD_LOGIC;
        
        h_sync              : out STD_LOGIC;
        v_sync              : out STD_LOGIC;
        vga_r               : out STD_LOGIC_VECTOR (3 downto 0);
        vga_g               : out STD_LOGIC_VECTOR (3 downto 0);
        vga_b               : out STD_LOGIC_VECTOR (3 downto 0)
    );
end controlador_vga;

architecture arc_controlador_vga of controlador_vga is

    constant H_DISPLAY : integer := 640;
    constant H_FP      : integer := 16;
    constant H_SYNC_P  : integer := 96;
    constant H_BP      : integer := 48;
    constant H_MAX     : integer := 800;

    constant V_DISPLAY : integer := 480;
    constant V_FP      : integer := 10;
    constant V_SYNC_P  : integer := 2;
    constant V_BP      : integer := 33;
    constant V_MAX     : integer := 525;

    signal contador_x : integer range 0 to H_MAX - 1 := 0;
    signal contador_y : integer range 0 to V_MAX - 1 := 0;
    
    signal video_on   : STD_LOGIC := '0';
    
    signal rojo       : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal verde      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal azul       : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

    -- Temporizador para efecto parpadeo (Aprox. 2 Hz)
    constant LIMITE_PARPADEO : integer := 12500000;
    signal cont_parpadeo     : integer range 0 to LIMITE_PARPADEO := 0;
    signal estado_parpadeo   : STD_LOGIC := '0';

begin

    proceso_barrido: process(reloj_vga_25mhz)
    begin
        if rising_edge(reloj_vga_25mhz) then
            if contador_x = H_MAX - 1 then
                contador_x <= 0;
                if contador_y = V_MAX - 1 then
                    contador_y <= 0;
                else
                    contador_y <= contador_y + 1;
                end if;
            else
                contador_x <= contador_x + 1;
            end if;
        end if;
    end process;

    h_sync <= '0' when (contador_x >= (H_DISPLAY + H_FP) and contador_x < (H_DISPLAY + H_FP + H_SYNC_P)) else '1';
    v_sync <= '0' when (contador_y >= (V_DISPLAY + V_FP) and contador_y < (V_DISPLAY + V_FP + V_SYNC_P)) else '1';

    video_on <= '1' when (contador_x < H_DISPLAY and contador_y < V_DISPLAY) else '0';

    proceso_parpadeo: process(reloj_vga_25mhz)
    begin
        if rising_edge(reloj_vga_25mhz) then
            if cont_parpadeo = LIMITE_PARPADEO - 1 then
                cont_parpadeo <= 0;
                estado_parpadeo <= not estado_parpadeo;
            else
                cont_parpadeo <= cont_parpadeo + 1;
            end if;
        end if;
    end process;

    proceso_graficos: process(video_on, contador_x, contador_y, sel_menu, data_in, dato_recibido, pin_sensor, alerta_interrupcion, estado_parpadeo)
    begin
        rojo  <= "0000"; verde <= "0000"; azul  <= "0000";

        if video_on = '1' then
            
            -- =====================================================
            -- A) INDICADORES DE MENÚ (Cuadrados Azules Y: 20 a 60)
            -- =====================================================
            if contador_y >= 20 and contador_y <= 60 then
                if (sel_menu = "00" or sel_menu = "01" or sel_menu = "10" or sel_menu = "11") and (contador_x >= 40 and contador_x <= 80) then
                    azul <= "1111"; 
                elsif (sel_menu = "01" or sel_menu = "10" or sel_menu = "11") and (contador_x >= 100 and contador_x <= 140) then
                    azul <= "1111"; 
                elsif (sel_menu = "10" or sel_menu = "11") and (contador_x >= 160 and contador_x <= 200) then
                    azul <= "1111"; 
                elsif (sel_menu = "11") and (contador_x >= 220 and contador_x <= 260) then
                    azul <= "1111"; 
                end if;
            end if;

            -- =====================================================
            -- B) LÓGICA POR MENÚ
            -- =====================================================
            case sel_menu is
                
                ---------------------------------------------------
                when "00" => -- MENU 1: Datos a enviar vs recibidos
                    if contador_y >= 120 and contador_y <= 160 then
                        if contador_x >= 100 and contador_x <= 140 then
                            if data_in(5) = '1' then verde <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 160 and contador_x <= 200 then
                            if data_in(4) = '1' then verde <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 220 and contador_x <= 260 then
                            if data_in(3) = '1' then verde <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 280 and contador_x <= 320 then
                            if data_in(2) = '1' then verde <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 340 and contador_x <= 380 then
                            if data_in(1) = '1' then verde <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 400 and contador_x <= 440 then
                            if data_in(0) = '1' then verde <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        end if;
                    end if;

                    if contador_y >= 220 and contador_y <= 260 then
                        if contador_x >= 100 and contador_x <= 140 then
                            if dato_recibido(5) = '1' then rojo <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 160 and contador_x <= 200 then
                            if dato_recibido(4) = '1' then rojo <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 220 and contador_x <= 260 then
                            if dato_recibido(3) = '1' then rojo <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 280 and contador_x <= 320 then
                            if dato_recibido(2) = '1' then rojo <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 340 and contador_x <= 380 then
                            if dato_recibido(1) = '1' then rojo <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        elsif contador_x >= 400 and contador_x <= 440 then
                            if dato_recibido(0) = '1' then rojo <= "1111"; else rojo <= "0100"; verde <= "0100"; azul <= "0100"; end if;
                        end if;
                    end if;

                ---------------------------------------------------
                when "01" => -- MENU 2: TX vs RX Continuo
                    if contador_y >= 200 and contador_y <= 300 and contador_x >= 150 and contador_x <= 250 then
                        if data_in(0) = '1' then verde <= "1111"; else rojo <= "1111"; end if;
                    end if;
                    
                    if contador_y >= 200 and contador_y <= 300 and contador_x >= 390 and contador_x <= 490 then
                        if pin_sensor = '0' then verde <= "1111"; else rojo <= "1111"; end if; -- Asume sensor invertido (0 = LUZ)
                    end if;

                    if data_in(0) = '1' and pin_sensor = '1' then -- Si TX envía y RX está en oscuridad
                        if contador_y >= 180 and contador_y <= 320 and contador_x >= 130 and contador_x <= 510 then
                            if contador_y < 190 or contador_y > 310 or contador_x < 140 or contador_x > 500 then
                                rojo <= "1111"; verde <= "0000"; azul <= "0000";
                            end if;
                        end if;
                    end if;

                ---------------------------------------------------
                when "10" => -- MENU 3: Calibración
                    if contador_y >= 150 and contador_y <= 350 and contador_x >= 220 and contador_x <= 420 then
                        if pin_sensor = '0' then -- Asume sensor invertido (0 = LUZ)
                            rojo <= "1111"; verde <= "1111"; azul <= "1111";
                        else
                            rojo <= "0010"; verde <= "0010"; azul <= "0010";
                        end if;
                    end if;

                ---------------------------------------------------
                when "11" => -- MENU 4: Cerradura Óptica (Secreta)
                    if contador_y >= 150 and contador_y <= 350 and contador_x >= 220 and contador_x <= 420 then
                        
                        -- Revisa la bandera (bit 15) para saber si llegó una clave
                        if dato_recibido(15) = '1' then 
                            -- Verifica si la llave coincide con la clave secreta (101010)
                            if dato_recibido(5 downto 0) = "110111" then
                                rojo <= "0000"; verde <= "1111"; azul <= "0000"; -- Acceso Concedido (VERDE)
                            else
                                rojo <= "1111"; verde <= "0000"; azul <= "0000"; -- Acceso Denegado (ROJO)
                            end if;
                        else
                            -- Si no ha llegado nada, la cerradura está en reposo
                            rojo <= "0100"; verde <= "0100"; azul <= "0100"; -- Bloqueado (GRIS)
                        end if;
                        
                    end if;

                when others =>
                    rojo <= "0000"; verde <= "0000"; azul <= "0000";
            end case;
        end if;
    end process;

    vga_r <= rojo  when video_on = '1' else "0000";
    vga_g <= verde when video_on = '1' else "0000";
    vga_b <= azul  when video_on = '1' else "0000";

end arc_controlador_vga;