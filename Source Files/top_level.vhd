library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    Port (
        reloj_100mhz : in  STD_LOGIC;
        btn_start    : in  STD_LOGIC;
        btn_stop     : in  STD_LOGIC;
        btn_reset    : in  STD_LOGIC;
        sel_menu     : in  STD_LOGIC_VECTOR (1 downto 0);
        data_in      : in  STD_LOGIC_VECTOR (5 downto 0);
        pin_sensor   : in  STD_LOGIC;
        pin_laser    : out STD_LOGIC;
        
        h_sync       : out STD_LOGIC;
        v_sync       : out STD_LOGIC;
        vga_r        : out STD_LOGIC_VECTOR (3 downto 0);
        vga_g        : out STD_LOGIC_VECTOR (3 downto 0);
        vga_b        : out STD_LOGIC_VECTOR (3 downto 0)
    );
end top_level;

architecture arc_top_level of top_level is
    
    component tiempos_debounce is
        Port (
            reloj_100mhz    : in  STD_LOGIC;
            btn_start_in    : in  STD_LOGIC;
            btn_stop_in     : in  STD_LOGIC;
            btn_reset_in    : in  STD_LOGIC;
            reloj_vga_25mhz : out STD_LOGIC;
            reloj_tx_2hz    : out STD_LOGIC; 
            btn_start_out   : out STD_LOGIC;
            btn_stop_out    : out STD_LOGIC;
            btn_reset_out   : out STD_LOGIC
        );
    end component;

    component transmisor_tx is
        Port (
            reloj_tx_2hz  : in  STD_LOGIC; 
            btn_start     : in  STD_LOGIC;
            btn_stop      : in  STD_LOGIC;
            sel_menu      : in  STD_LOGIC_VECTOR (1 downto 0);
            data_in       : in  STD_LOGIC_VECTOR (5 downto 0);
            pin_laser     : out STD_LOGIC
        );
    end component;

    component receptor_rx is
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
    end component;

    component controlador_vga is
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
    end component;

    signal sig_reloj_vga : STD_LOGIC;
    signal sig_reloj_tx  : STD_LOGIC;
    
    signal sig_btn_start : STD_LOGIC;
    signal sig_btn_stop  : STD_LOGIC;
    signal sig_btn_reset : STD_LOGIC;
    
    signal sig_dato_recibido       : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_errores_totales     : integer range 0 to 9999;
    signal sig_alerta_interrupcion : STD_LOGIC;

begin

    U1_Tiempos: tiempos_debounce
        Port map (
            reloj_100mhz    => reloj_100mhz,
            btn_start_in    => btn_start,
            btn_stop_in     => btn_stop,
            btn_reset_in    => btn_reset,
            reloj_vga_25mhz => sig_reloj_vga,
            reloj_tx_2hz    => sig_reloj_tx,
            btn_start_out   => sig_btn_start,
            btn_stop_out    => sig_btn_stop,
            btn_reset_out   => sig_btn_reset
        );

    U2_Transmisor: transmisor_tx
        Port map (
            reloj_tx_2hz  => sig_reloj_tx,
            btn_start     => sig_btn_start,
            btn_stop      => sig_btn_stop,
            sel_menu      => sel_menu,
            data_in       => data_in,
            pin_laser     => pin_laser
        );

    U3_Receptor: receptor_rx
        Port map (
            reloj_rx_2hz        => sig_reloj_tx,
            btn_reset           => sig_btn_reset,
            btn_stop            => sig_btn_stop,
            pin_sensor          => pin_sensor,
            sel_menu            => sel_menu,
            data_in             => data_in,
            dato_recibido       => sig_dato_recibido,
            errores_totales     => sig_errores_totales,
            alerta_interrupcion => sig_alerta_interrupcion
        );

    U4_VGA: controlador_vga
        Port map (
            reloj_vga_25mhz     => sig_reloj_vga,
            sel_menu            => sel_menu,
            data_in             => data_in,
            dato_recibido       => sig_dato_recibido,
            pin_sensor          => pin_sensor,
            errores_totales     => sig_errores_totales,
            alerta_interrupcion => sig_alerta_interrupcion,
            h_sync              => h_sync,
            v_sync              => v_sync,
            vga_r               => vga_r,
            vga_g               => vga_g,
            vga_b               => vga_b
        );

end arc_top_level;