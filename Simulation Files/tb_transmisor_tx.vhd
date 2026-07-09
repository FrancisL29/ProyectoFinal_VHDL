----------------------------------------------------------------------------------
-- Testbench: tb_transmisor_tx
-- Descripcion: Banco de pruebas para la FSM del transmisor optico.
--              Verifica el Menu 1 (Envio Manual): al presionar START con
--              sel_menu = "00" y una palabra en data_in, la maquina de estados
--              debe recorrer REPOSO -> PREPARAR_TRAMA -> ENVIANDO -> PAUSA -> REPOSO
--              generando en pin_laser la trama serial: bit de arranque '1',
--              los 6 bits de datos (MSB primero) y un bit de guarda '0'.
--
--  Como usarlo en Vivado:
--    1. Add Sources -> Add or create simulation sources -> este archivo.
--    2. Set as Top (simulation): tb_transmisor_tx.
--    3. Run Simulation -> Run Behavioral Simulation.
--    4. Observar 'estado_actual' y 'pin_laser' en el waveform y capturarlo.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_transmisor_tx is
end tb_transmisor_tx;

architecture sim of tb_transmisor_tx is

    component transmisor_tx is
        Port (
            reloj_tx_2hz : in  STD_LOGIC;
            btn_start    : in  STD_LOGIC;
            btn_stop     : in  STD_LOGIC;
            sel_menu     : in  STD_LOGIC_VECTOR (1 downto 0);
            data_in      : in  STD_LOGIC_VECTOR (5 downto 0);
            pin_laser    : out STD_LOGIC
        );
    end component;

    signal reloj_tx_2hz : STD_LOGIC := '0';
    signal btn_start    : STD_LOGIC := '0';
    signal btn_stop     : STD_LOGIC := '0';
    signal sel_menu     : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal data_in      : STD_LOGIC_VECTOR (5 downto 0) := "101101";
    signal pin_laser    : STD_LOGIC;

    -- Periodo acelerado para simulacion (en hardware real son 2 Hz)
    constant T_CLK : time := 10 ns;

begin

    uut: transmisor_tx
        port map (
            reloj_tx_2hz => reloj_tx_2hz,
            btn_start    => btn_start,
            btn_stop     => btn_stop,
            sel_menu     => sel_menu,
            data_in      => data_in,
            pin_laser    => pin_laser
        );

    -- Generacion del reloj de transmision
    reloj_tx_2hz <= not reloj_tx_2hz after T_CLK/2;

    -- Estimulos
    estimulos: process
    begin
        -- Modo Menu 1 (envio manual) con la palabra 101101
        sel_menu <= "00";
        data_in  <= "101101";
        btn_stop <= '0';
        btn_start<= '0';
        wait for 4*T_CLK;

        -- Pulso de START para disparar la trama
        btn_start <= '1';
        wait for 2*T_CLK;
        btn_start <= '0';

        -- Dejar correr la transmision completa (8 bits + pausa)
        wait for 20*T_CLK;

        -- Prueba de una segunda palabra
        data_in  <= "010010";
        btn_start<= '1';
        wait for 2*T_CLK;
        btn_start<= '0';
        wait for 20*T_CLK;

        assert false report "Fin de la simulacion" severity failure;
    end process;

end sim;
