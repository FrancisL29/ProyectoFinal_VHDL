library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tiempos_debounce is
    Port (
        reloj_100mhz    : in  STD_LOGIC;
        btn_start_in    : in  STD_LOGIC;
        btn_stop_in     : in  STD_LOGIC;
        btn_reset_in    : in  STD_LOGIC;
        
        reloj_vga_25mhz : out STD_LOGIC;
        reloj_tx_2hz    : out STD_LOGIC; -- ¡Renombrado a 2Hz!
        btn_start_out   : out STD_LOGIC;
        btn_stop_out    : out STD_LOGIC;
        btn_reset_out   : out STD_LOGIC
    );
end tiempos_debounce;

architecture arc_tiempos_debounce of tiempos_debounce is

    signal contador_vga : unsigned(1 downto 0) := (others => '0');
    signal aux_reloj_vga : STD_LOGIC := '0';

    -- Nuevo límite para 2 Hz: 100,000,000 / (2 * 2) = 25,000,000
    constant LIMITE_2HZ : integer := 25000000;
    signal contador_tx  : integer range 0 to LIMITE_2HZ := 0;
    signal aux_reloj_tx : STD_LOGIC := '0';

    constant MAX_REBOTE  : integer := 1000000;
    
    signal cont_start    : integer range 0 to MAX_REBOTE := 0;
    signal estado_start  : STD_LOGIC := '0';
    
    signal cont_stop     : integer range 0 to MAX_REBOTE := 0;
    signal estado_stop   : STD_LOGIC := '0';
    
    signal cont_reset    : integer range 0 to MAX_REBOTE := 0;
    signal estado_reset  : STD_LOGIC := '0';

begin

    proceso_reloj_vga: process(reloj_100mhz)
    begin
        if rising_edge(reloj_100mhz) then
            contador_vga <= contador_vga + 1;
            aux_reloj_vga <= contador_vga(1); 
        end if;
    end process;
    
    reloj_vga_25mhz <= aux_reloj_vga;

    proceso_reloj_tx: process(reloj_100mhz)
    begin
        if rising_edge(reloj_100mhz) then
            if contador_tx = LIMITE_2HZ - 1 then
                contador_tx <= 0;
                aux_reloj_tx <= not aux_reloj_tx;
            else
                contador_tx <= contador_tx + 1;
            end if;
        end if;
    end process;
    
    reloj_tx_2hz <= aux_reloj_tx;

    proceso_debounce: process(reloj_100mhz)
    begin
        if rising_edge(reloj_100mhz) then
            -- Antirrebote START
            if btn_start_in /= estado_start then
                cont_start <= cont_start + 1;
                if cont_start = MAX_REBOTE - 1 then
                    estado_start <= btn_start_in;
                    cont_start <= 0;
                end if;
            else
                cont_start <= 0;
            end if;

            -- Antirrebote STOP
            if btn_stop_in /= estado_stop then
                cont_stop <= cont_stop + 1;
                if cont_stop = MAX_REBOTE - 1 then
                    estado_stop <= btn_stop_in;
                    cont_stop <= 0;
                end if;
            else
                cont_stop <= 0;
            end if;

            -- Antirrebote RESET
            if btn_reset_in /= estado_reset then
                cont_reset <= cont_reset + 1;
                if cont_reset = MAX_REBOTE - 1 then
                    estado_reset <= btn_reset_in;
                    cont_reset <= 0;
                end if;
            else
                cont_reset <= 0;
            end if;
        end if;
    end process;

    btn_start_out <= estado_start;
    btn_stop_out  <= estado_stop;
    btn_reset_out <= estado_reset;

end arc_tiempos_debounce;