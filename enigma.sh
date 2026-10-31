#!/bin/bash
LETRAS="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

function iniciar {
    if test "$#" -eq 1 -a "$1" = "-g"; then
        echo "=========================================================="
        echo "            JUEGO 'EL ENIGMA' - MODO INFORMACIÓN          "
        echo "=========================================================="
        echo "Integrantes del grupo: Javier Martin Vicente y Alejandro De La Torre Garcia"
        echo "Estrategia IA propia (ESTRATEGIA=2): prueba las letras en orden de frecuencia aproximada del castellano: E, A, O, S, R, N, I, D, L, C, T, U, M, P, B, G, V, Y, Q, H, F, J, Z, X, K, W."
        echo "Estadística libre: porcentaje de partidas sin ganador. Cuenta las partidas en las que todas las rondas quedaron desiertas."
        echo "=========================================================="
        return 0
    elif test "$#" -gt 0; then
        echo "Sintaxis incorrecta. Modo correcto de uso: $0 [-g]"
        return 1
    fi
    case "$0" in
        */*) CARPETA="${0%/*}" ;;
        *) CARPETA="." ;; esac
    if ! cd "$CARPETA"; then
        echo "Error: no se puede acceder al directorio del programa."
        return 1; fi
    CARPETA="$PWD"
    if ! leer_configuracion; then
        return 1; fi
    if ! leer_frases; then
        return 1; fi
    OPCION=""
    while test "$OPCION" != "S" -a "$OPCION" != "s"; do
        clear
        echo '=================='
        echo 'JUEGO “EL ENIGMA”'
        echo '=================='
        echo "C) CONFIGURACIÓN"
        echo "J) JUGAR"
        echo "F) FRASES"
        echo "E) ESTADÍSTICAS"
        echo "S) SALIR"
        echo -n "Introduzca una opción >> "
        if ! read -r OPCION; then
            echo
            echo "Fin de la entrada. El programa termina."
            return 0; fi
        case "$OPCION" in
            C|c)
                echo
                echo "--- C) CONFIGURACIÓN ---"
                editar_configuracion ;;
            J|j)
                echo
                echo "--- J) JUGAR ---"
                jugar ;;
            F|f)
                echo
                echo "--- F) FRASES ---"
                menu_frases ;;
            E|e)
                echo
                echo "--- E) ESTADÍSTICAS ---"
                ver_estadisticas ;;
            S|s)
                echo
                echo "Devolviendo el control al sistema..." ;;
            *)
                echo
                echo "Opción no válida. Inténtelo de nuevo." ;; esac
        if test "$OPCION" != "S" -a "$OPCION" != "s"; then
            pausa; fi
    done
}
function leer {
    if ! read -r; then
        echo
        echo "Fin de la entrada. El programa termina."
        exit 0; fi
}
function mayusculas {
    ENTRADA="$1"
    SALIDA=""
    POS=0
    while test "$POS" -lt "${#ENTRADA}"; do
        CARACTER="${ENTRADA:$POS:1}"
        case "$CARACTER" in
            a) CARACTER=A ;; b) CARACTER=B ;; c) CARACTER=C ;; d) CARACTER=D ;; e) CARACTER=E ;;
            f) CARACTER=F ;; g) CARACTER=G ;; h) CARACTER=H ;; i) CARACTER=I ;; j) CARACTER=J ;;
            k) CARACTER=K ;; l) CARACTER=L ;; m) CARACTER=M ;; n) CARACTER=N ;; o) CARACTER=O ;;
            p) CARACTER=P ;; q) CARACTER=Q ;; r) CARACTER=R ;; s) CARACTER=S ;; t) CARACTER=T ;;
            u) CARACTER=U ;; v) CARACTER=V ;; w) CARACTER=W ;; x) CARACTER=X ;; y) CARACTER=Y ;; z) CARACTER=Z ;; esac
        SALIDA="$SALIDA$CARACTER"
        POS=$((POS + 1))
    done
    MAYUS="$SALIDA"
}
function entero {
    case "$1" in
        ""|*[!0123456789]*) return 1 ;;
        *) return 0 ;; esac
}
function quitar_ceros {
    NUMERO="$1"
    while test "${#NUMERO}" -gt 1 -a "${NUMERO:0:1}" = "0"; do NUMERO="${NUMERO:1}"; done
}
function frase_correcta {
    case "$1" in
        ""|*[!$LETRAS\ ]*) return 1 ;;
        *[$LETRAS]*) return 0 ;;
        *) return 1 ;; esac
}
function buscar_parametro {
    case "$1" in
        JUGADORES) POSICION=0 ;;
        RONDAS) POSICION=1 ;;
        PVIDA) POSICION=2 ;;
        PFALLO) POSICION=3 ;;
        PRESPUESTA) POSICION=4 ;;
        CATEGORIAS) POSICION=5 ;;
        ESTRATEGIA) POSICION=6 ;;
        LOG) POSICION=7 ;;
        *) POSICION=-1 ;; esac
}
function configuracion_valida {
    if test "${CONFIG[0]}" -lt 2 -o "${CONFIG[0]}" -gt 4 \
        -o "${CONFIG[1]}" -lt 1 \
        -o "${CONFIG[2]}" -lt 50 -o "${CONFIG[2]}" -gt 100 \
        -o "${CONFIG[3]}" -lt 5 -o "${CONFIG[3]}" -gt 10 \
        -o "${CONFIG[4]}" -le "${CONFIG[3]}" \
        -o "${CONFIG[4]}" -ge "${CONFIG[2]}" \
        -o "${CONFIG[5]}" -lt 1 -o "${CONFIG[5]}" -gt 4 \
        -o "${CONFIG[6]}" -lt 0 -o "${CONFIG[6]}" -gt 2; then
        return 1; fi
    if test -z "${CONFIG[7]}"; then
        return 1; fi
    case "${CONFIG[7]}" in *'|'*) return 1 ;; esac
    return 0
}
function leer_configuracion {
    if test ! -f config.cfg -o ! -r config.cfg; then
        echo "Error: config.cfg no existe o no se puede leer."
        return 1; fi
    CONFIG=()
    PARAMETROS_VISTOS=()
    for PARAMETRO in JUGADORES RONDAS PVIDA PFALLO PRESPUESTA CATEGORIAS ESTRATEGIA LOG; do
        buscar_parametro "$PARAMETRO"
        PARAMETROS_VISTOS[$POSICION]=0
    done
    ERROR=0
    LINEA=""
    while read -r LINEA || test -n "$LINEA"; do
        case "$LINEA" in
            *$'\r') LINEA="${LINEA%$'\r'}" ;; esac

        if test -z "$LINEA"; then
            continue; fi
        case "$LINEA" in
            *=*) PARAMETRO="${LINEA%%=*}"; VALOR="${LINEA#*=}" ;;
            *) echo "Error: falta = en config.cfg."; ERROR=1; PARAMETRO="" ;; esac
        buscar_parametro "$PARAMETRO"
        if test "$POSICION" -lt 0; then
            echo "Error: parámetro desconocido en config.cfg."
            ERROR=1
        elif test "${PARAMETROS_VISTOS[$POSICION]}" -eq 1; then
            echo "Error: parámetro repetido en config.cfg: $PARAMETRO."
            ERROR=1
        else
            PARAMETROS_VISTOS[$POSICION]=1
            CONFIG[$POSICION]="$VALOR"
        fi
        LINEA=""
    done < config.cfg
    for PARAMETRO in JUGADORES RONDAS PVIDA PFALLO PRESPUESTA CATEGORIAS ESTRATEGIA LOG; do
        buscar_parametro "$PARAMETRO"
        if test "${PARAMETROS_VISTOS[$POSICION]}" -ne 1; then
            echo "Error: falta el parámetro $PARAMETRO en config.cfg."
            ERROR=1; fi
    done
    if test "$ERROR" -eq 1; then
        echo "Error: config.cfg no es válido."
        return 1; fi
    for POSICION in 0 1 2 3 4 5 6; do
        if ! entero "${CONFIG[$POSICION]}"; then
            echo "Error: los parámetros numéricos de config.cfg deben ser enteros."
            return 1; fi
        quitar_ceros "${CONFIG[$POSICION]}"
        CONFIG[$POSICION]="$NUMERO"
    done
    if ! configuracion_valida; then
        echo "Error: los valores de config.cfg no cumplen los límites de la práctica."
        return 1; fi
    JUGADORES="${CONFIG[0]}"
    RONDAS="${CONFIG[1]}"
    PVIDA="${CONFIG[2]}"
    PFALLO="${CONFIG[3]}"
    PRESPUESTA="${CONFIG[4]}"
    CATEGORIAS="${CONFIG[5]}"
    ESTRATEGIA="${CONFIG[6]}"
    RUTA_LOG="${CONFIG[7]}"
    return 0
}
function nivel_categoria {
    case "$1" in
        REFRAN) NIVEL=1 ;;
        PELICULA) NIVEL=2 ;;
        MUSICA) NIVEL=3 ;;
        DEPORTE) NIVEL=4 ;;
        *) NIVEL=0 ;; esac
}
function leer_frases {
    if test ! -f frases.dat -o ! -r frases.dat; then
        echo "Error: frases.dat no existe o no se puede leer."
        return 1; fi
    FRASES=()
    CATEGORIAS_FRASE=()
    ERROR=0
    LINEA=""
    while read -r LINEA || test -n "$LINEA"; do
        case "$LINEA" in
            *$'\r') LINEA="${LINEA%$'\r'}" ;; esac

        if test -z "$LINEA"; then
            continue; fi
        case "$LINEA" in
            *:*) CATEGORIA="${LINEA%%:*}"; TEXTO="${LINEA#*:}" ;;
            *) echo "Error: falta : en frases.dat."; ERROR=1; CATEGORIA="" ;; esac
        nivel_categoria "$CATEGORIA"
        if test "$NIVEL" -eq 0; then
            echo "Error: categoría incorrecta en frases.dat."
            ERROR=1
        elif ! frase_correcta "$TEXTO"; then
            echo "Error: frase no válida en frases.dat. Use mayúsculas y espacios."
            ERROR=1
        else
            REPETIDA=0
            POS=0
            while test "$POS" -lt "${#FRASES[@]}"; do
                if test "${FRASES[$POS]}" = "$TEXTO"; then
                    REPETIDA=1; fi
                POS=$((POS + 1))
            done
            if test "$REPETIDA" -eq 0; then
                FRASES[${#FRASES[@]}]="$TEXTO"
                CATEGORIAS_FRASE[${#CATEGORIAS_FRASE[@]}]="$CATEGORIA"; fi; fi
        LINEA=""
    done < frases.dat
    if test "$ERROR" -eq 1; then
        echo "Error: frases.dat no es válido."
        return 1; fi
    if test "${#FRASES[@]}" -eq 0; then
        echo "Error: frases.dat no contiene frases válidas."
        return 1; fi
    return 0
}
function preparar_frases_disponibles {
    FRASES_DISPONIBLES=()
    POS=0
    while test "$POS" -lt "${#FRASES[@]}"; do
        nivel_categoria "${CATEGORIAS_FRASE[$POS]}"
        if test "$NIVEL" -le "$CATEGORIAS"; then
            FRASES_DISPONIBLES[${#FRASES_DISPONIBLES[@]}]="$POS"; fi
        POS=$((POS + 1))
    done
}
function pausa {
    echo "Pulse una tecla para continuar."
    if ! read -r -n 1; then
        echo
        echo "Fin de la entrada. El programa termina."
        exit 0; fi
    echo
}
function pedir_numero {
    NOMBRE_DATO="$1"
    VALOR_ACTUAL="$2"
    MINIMO="$3"
    MAXIMO="$4"
    VALOR_ACEPTADO=0
    while test "$VALOR_ACEPTADO" -eq 0; do
        if test "$MAXIMO" -eq 0; then
            echo -n "$NOMBRE_DATO (actual $VALOR_ACTUAL, mínimo $MINIMO; Intro conserva): "
        else
            echo -n "$NOMBRE_DATO (actual $VALOR_ACTUAL, de $MINIMO a $MAXIMO; Intro conserva): "; fi
        leer
        DATO_NUEVO="$REPLY"
        if test -z "$DATO_NUEVO"; then
            DATO_NUEVO="$VALOR_ACTUAL"; fi
        if entero "$DATO_NUEVO"; then
            quitar_ceros "$DATO_NUEVO"
            DATO_NUEVO="$NUMERO"
            if test "$DATO_NUEVO" -ge "$MINIMO" \
                -a \( "$MAXIMO" -eq 0 -o "$DATO_NUEVO" -le "$MAXIMO" \); then
                VALOR_ACEPTADO=1; fi; fi
        if test "$VALOR_ACEPTADO" -eq 0; then
            echo "Valor no válido."; fi
    done
    DATO_PEDIDO="$DATO_NUEVO"
}
function guardar_configuracion {
    if test ! -w config.cfg; then
        echo "Error: no se puede escribir config.cfg."
        return 1; fi
    if ! {
        for PARAMETRO in JUGADORES RONDAS PVIDA PFALLO PRESPUESTA CATEGORIAS ESTRATEGIA LOG; do
            buscar_parametro "$PARAMETRO"
            echo "$PARAMETRO=${CONFIG[$POSICION]}"
        done
    } > config.cfg; then
        echo "Error al guardar config.cfg."
        return 1; fi
    leer_configuracion
}
function editar_configuracion {
    echo "CONFIGURACIÓN ACTUAL"
    for PARAMETRO in JUGADORES RONDAS PVIDA PFALLO PRESPUESTA CATEGORIAS ESTRATEGIA LOG; do
        buscar_parametro "$PARAMETRO"
        echo "$PARAMETRO=${CONFIG[$POSICION]}"
    done
    echo "Intro conserva el valor actual."
    pedir_numero PFALLO "${CONFIG[3]}" 5 10
    CONFIG[3]="$DATO_PEDIDO"
    pedir_numero PRESPUESTA "${CONFIG[4]}" "$((CONFIG[3] + 1))" 99
    CONFIG[4]="$DATO_PEDIDO"
    pedir_numero PVIDA "${CONFIG[2]}" "$((CONFIG[4] + 1))" 100
    CONFIG[2]="$DATO_PEDIDO"
    pedir_numero JUGADORES "${CONFIG[0]}" 2 4
    CONFIG[0]="$DATO_PEDIDO"
    pedir_numero RONDAS "${CONFIG[1]}" 1 0
    CONFIG[1]="$DATO_PEDIDO"
    pedir_numero CATEGORIAS "${CONFIG[5]}" 1 4
    CONFIG[5]="$DATO_PEDIDO"
    pedir_numero ESTRATEGIA "${CONFIG[6]}" 0 2
    CONFIG[6]="$DATO_PEDIDO"
    echo -n "LOG (actual ${CONFIG[7]}, Intro conserva): "
    leer
    if test -n "$REPLY"; then
        case "$REPLY" in
            *'|'*) echo "Ruta no válida; no se guardaron los cambios."; return ;;
            *) CONFIG[7]="$REPLY" ;; esac; fi
    if configuracion_valida; then
        if guardar_configuracion; then
            echo "Configuración guardada."; fi
    else
        echo "Configuración no válida; no se guardaron los cambios."; fi
}
function ver_frases {
    if leer_frases; then
        POS=0
        while test "$POS" -lt "${#FRASES[@]}"; do
            echo "${CATEGORIAS_FRASE[$POS]}:${FRASES[$POS]}"
            POS=$((POS + 1))
        done; fi
}
function anadir_frase {
    echo -n "Categoría (REFRAN, PELICULA, MUSICA o DEPORTE): "
    leer
    mayusculas "$REPLY"
    CATEGORIA="$MAYUS"
    CATEGORIA_NUEVA="$CATEGORIA"
    nivel_categoria "$CATEGORIA"
    if test "$NIVEL" -eq 0; then
        echo "Categoría no válida."
        return; fi
    echo -n "Frase (letras y espacios): "
    leer
    mayusculas "$REPLY"
    FRASE_NUEVA="$MAYUS"

    if ! frase_correcta "$FRASE_NUEVA"; then
        echo "Frase no válida. Use letras sin acentos ni caracteres especiales."
        return; fi
    if ! leer_frases; then
        return; fi
    POS=0
    while test "$POS" -lt "${#FRASES[@]}"; do
        if test "${FRASES[$POS]}" = "$FRASE_NUEVA"; then
            echo "La frase ya existe."
            return; fi
        POS=$((POS + 1))
    done
    if test ! -w frases.dat; then
        echo "Error: no se puede escribir frases.dat."
    else
        LINEA=""
        while IFS= read -r LINEA; do
            LINEA=""
        done < frases.dat
        if test -n "$LINEA"; then
            echo >> frases.dat; fi
        if echo "$CATEGORIA_NUEVA:$FRASE_NUEVA" >> frases.dat; then
            echo "Frase añadida."
            leer_frases
        else
            echo "Error al guardar la frase."; fi; fi
}
function menu_frases {
    SALIR_FRASES=0
    while test "$SALIR_FRASES" -eq 0; do
        echo "FRASES"
        echo "V) VER LAS FRASES"
        echo "A) AÑADIR UNA FRASE"
        echo "S) VOLVER AL MENÚ"
        echo -n "Introduzca una opción >> "
        leer
        case "$REPLY" in
            V|v) ver_frases ;;
            A|a) anadir_frase ;;
            S|s) SALIR_FRASES=1 ;;
            *) echo "Opción no válida." ;; esac
        if test "$SALIR_FRASES" -eq 0; then
            pausa; fi
    done
}
function preparar_log {
    buscar_ruta_log
    DIR_LOG="${ARCHIVO_LOG%/*}"
    if test -z "$DIR_LOG"; then
        DIR_LOG="/"; fi
    if test ! -d "$DIR_LOG"; then
        if ! mkdir -p "$DIR_LOG"; then
            echo "Error: no se puede crear el directorio del LOG."
            return 1; fi; fi
    if test -d "$ARCHIVO_LOG"; then
        echo "Error: la ruta LOG corresponde a un directorio."
        return 1; fi
    if ! touch "$ARCHIVO_LOG"; then
        echo "Error: no se puede crear o escribir el LOG."
        return 1; fi
    if test ! -w "$ARCHIVO_LOG"; then
        echo "Error: no se puede escribir el LOG."
        return 1; fi
    return 0
}
function letra_ya_usada {
    case "$LETRAS_USADAS" in *"$1"*) return 0 ;; *) return 1 ;; esac
}
function mostrar_frase_oculta {
    FRASE_OCULTA=""
    POS=0
    while test "$POS" -lt "${#FRASE}"; do
        CARACTER="${FRASE:$POS:1}"
        if test "$CARACTER" = " "; then
            FRASE_OCULTA="$FRASE_OCULTA "
        elif letra_ya_usada "$CARACTER"; then
            FRASE_OCULTA="$FRASE_OCULTA$CARACTER"
        else
            FRASE_OCULTA="${FRASE_OCULTA}_"; fi
        POS=$((POS + 1))
    done
}
function mostrar_turno {
    mostrar_frase_oculta
    echo
    echo "Categoría: $CATEGORIA_PARTIDA"
    echo "Ronda: $RONDA/$RONDAS"
    echo "Frase: $FRASE_OCULTA"
    echo "Jugadores y vidas:"
    INDICE=1
    while test "$INDICE" -le "$JUGADORES"; do
        echo "Jugador $INDICE: ${VIDAS[$INDICE]}"
        INDICE=$((INDICE + 1))
    done
    echo "Turno: jugador $TURNO"
    if test -z "$LETRAS_USADAS"; then
        echo "Letras utilizadas: ninguna"
    else
        echo "Letras utilizadas: $LETRAS_USADAS"; fi
    echo "Acciones: A) SOLICITAR LETRA   R) RESOLVER FRASE"
}
function pedir_letra {
    LETRA_IA=""
    while test -z "$LETRA_IA"; do
        echo -n "Introduzca una letra >> "
        leer
        mayusculas "$REPLY"
        if test "${#MAYUS}" -ne 1; then
            echo "Debe introducir una sola letra."
        else
            case "$MAYUS" in
                    [$LETRAS])
                    if letra_ya_usada "$MAYUS"; then
                        echo "Esa letra ya se utilizó. Introduzca otra."
                    else
                        LETRA_IA="$MAYUS"; fi
                    ;;
                *) echo "Introduzca una letra de la A a la Z." ;; esac; fi
    done
}
function pedir_respuesta {
    RESPUESTA=""
    while test -z "$RESPUESTA"; do
        echo -n "Introduzca la frase completa >> "
        leer
        mayusculas "$REPLY"
        if frase_correcta "$MAYUS"; then
            RESPUESTA="$MAYUS"
        else
            echo "Use letras y espacios, sin acentos ni caracteres especiales."; fi
    done
}
function siguiente_jugador {
    TURNO=$((TURNO + 1))
    if test "$TURNO" -gt "$JUGADORES"; then
        TURNO=1; fi
}
function quitar_vida {
    NUEVA_VIDA=$((VIDAS[$TURNO] - PERDIDA_VIDA))
    if test "$NUEVA_VIDA" -le 0; then
        VIDAS[$TURNO]=0
        echo "Jugador $TURNO eliminado de esta ronda."
    else
        VIDAS[$TURNO]="$NUEVA_VIDA"
        echo "Jugador $TURNO pierde $PERDIDA_VIDA vidas."; fi
}
function ganar_ronda {
    echo "Gana la ronda el jugador $TURNO."
    RONDAS_GANADAS[$TURNO]=$((RONDAS_GANADAS[$TURNO] + 1))
    FRASES_RESUELTAS=$((FRASES_RESUELTAS + 1))
    FIN_RONDA=1
}
function comprobar_letra {
    TOTAL_LETRAS=$((TOTAL_LETRAS + 1))
    LETRAS_USADAS="$LETRAS_USADAS$LETRA_IA"
    case "$FRASE" in
        *"$LETRA_IA"*)
            echo "Letra correcta."
            mostrar_frase_oculta
            echo "Frase: $FRASE_OCULTA"
            case "$FRASE_OCULTA" in
                *_*) ;;
                *) ganar_ronda ;; esac
            ;;
        *)
            echo "Letra incorrecta."
            PERDIDA_VIDA="$PFALLO"
            quitar_vida
            siguiente_jugador
            ;; esac
}
function comprobar_respuesta {
    if test "$RESPUESTA" = "$FRASE"; then
        echo "Respuesta correcta."
        ganar_ronda
    else
        echo "Respuesta incorrecta."
        PERDIDA_VIDA="$PRESPUESTA"
        quitar_vida
        siguiente_jugador; fi
}
function letra_de_ia {
    LETRA_IA=""
    if test "$ESTRATEGIA" -eq 1; then
        while test -z "$LETRA_IA"; do
            AZAR=$((RANDOM % ${#LETRAS}))
            LETRA_CANDIDATA="${LETRAS:$AZAR:1}"
            if ! letra_ya_usada "$LETRA_CANDIDATA"; then
                LETRA_IA="$LETRA_CANDIDATA"
            fi
        done
    else
        if test "$ESTRATEGIA" -eq 0; then
            ORDEN_LETRAS="$LETRAS"
        else
            ORDEN_LETRAS="EAOSRNIDLCTUMPBGVYQHFJZXKW"
        fi
        POS=0
        while test "$POS" -lt "${#ORDEN_LETRAS}" -a -z "$LETRA_IA"; do
            LETRA_CANDIDATA="${ORDEN_LETRAS:$POS:1}"
            if ! letra_ya_usada "$LETRA_CANDIDATA"; then
                LETRA_IA="$LETRA_CANDIDATA"
            fi
            POS=$((POS + 1))
        done
    fi
}
function registrar_partida {
    if ! preparar_log; then
        echo "Error: no se pudo guardar el resultado de la partida."
        return 1; fi
    CABECERA="FECHA|HORA|TPO|JUGADORES|RONDAS|PVIDA|PFALLO|PRESPUESTA|CATEGORIAS|ESTRATEGIA|GANADOR|RONDAS_GANADAS_J1|RONDAS_GANADAS_J2|RONDAS_GANADAS_J3|RONDAS_GANADAS_J4|LETRAS_UTILIZADAS|FRASES_RESUELTAS"
    if test ! -s "$ARCHIVO_LOG"; then
        echo "$CABECERA" >> "$ARCHIVO_LOG"; fi
    FECHA=$(date '+%d%m%y')
    HORA=$(date '+%H:%M:%S')
    RONDAS_GUARDADAS=()
    for INDICE in 1 2 3 4; do
        if test "$INDICE" -le "$JUGADORES"; then
            RONDAS_GUARDADAS[$INDICE]="${RONDAS_GANADAS[$INDICE]}"
        else
            RONDAS_GUARDADAS[$INDICE]="-"; fi
    done
    if echo "$FECHA|$HORA|$TIEMPO|$JUGADORES|$RONDAS|$PVIDA|$PFALLO|$PRESPUESTA|$CATEGORIAS|$ESTRATEGIA|$GANADOR|${RONDAS_GUARDADAS[1]}|${RONDAS_GUARDADAS[2]}|${RONDAS_GUARDADAS[3]}|${RONDAS_GUARDADAS[4]}|$TOTAL_LETRAS|$FRASES_RESUELTAS" >> "$ARCHIVO_LOG"; then
        echo "Resultado añadido al LOG: $RUTA_LOG"
    else
        echo "Error al escribir el resultado en el LOG."
        return 1; fi
}
function jugar {
    if ! leer_configuracion; then
        return; fi
    if ! leer_frases; then
        return; fi
    preparar_frases_disponibles
    if test "${#FRASES_DISPONIBLES[@]}" -lt "$RONDAS"; then
        echo "No hay suficientes frases distintas en las categorías habilitadas."
        echo "Se necesitan $RONDAS y hay ${#FRASES_DISPONIBLES[@]}."
        return; fi
    if ! preparar_log; then
        echo "No se inicia la partida porque no se puede garantizar el registro."
        return; fi
    FRASES_USADAS=()
    VIDAS=()
    RONDAS_GANADAS=()
    TOTAL_LETRAS=0
    FRASES_RESUELTAS=0
    for INDICE in 1 2 3 4; do
        RONDAS_GANADAS[$INDICE]=0
    done
    SECONDS=0
    RONDA=1
    while test "$RONDA" -le "$RONDAS"; do
        echo
        echo "========== RONDA $RONDA =========="
        for INDICE in 1 2 3 4; do
            if test "$INDICE" -le "$JUGADORES"; then
                VIDAS[$INDICE]="$PVIDA"; fi
        done
        AZAR=$((RANDOM % ${#FRASES_DISPONIBLES[@]}))
        INDICE_FRASE="${FRASES_DISPONIBLES[$AZAR]}"
        while test "${FRASES_USADAS[$INDICE_FRASE]}" = 1; do
            AZAR=$((RANDOM % ${#FRASES_DISPONIBLES[@]}))
            INDICE_FRASE="${FRASES_DISPONIBLES[$AZAR]}"
        done
        FRASES_USADAS[$INDICE_FRASE]=1
        FRASE="${FRASES[$INDICE_FRASE]}"
        CATEGORIA_PARTIDA="${CATEGORIAS_FRASE[$INDICE_FRASE]}"
        LETRAS_USADAS=""
        TURNO=1
        FIN_RONDA=0
        while test "$FIN_RONDA" -eq 0; do
            JUGADORES_ACTIVOS=0
            for INDICE in 1 2 3 4; do
                if test "$INDICE" -le "$JUGADORES"; then
                    if test "${VIDAS[$INDICE]}" -gt 0; then
                        JUGADORES_ACTIVOS=$((JUGADORES_ACTIVOS + 1)); fi; fi
            done
            if test "$JUGADORES_ACTIVOS" -eq 0; then
                echo "Ronda desierta: todos los jugadores han sido eliminados."
                FIN_RONDA=1
            else
                while test "${VIDAS[$TURNO]}" -le 0; do
                    siguiente_jugador
                done
                mostrar_turno
                if test "$TURNO" -eq 1; then
                    echo -n "Introduzca una opción >> "
                    leer
                    case "$REPLY" in
                        A|a) pedir_letra; comprobar_letra ;;
                        R|r) pedir_respuesta; comprobar_respuesta ;;
                        *) echo "Opción no válida. Conserva el turno." ;; esac
                else
                    echo "Turno de la IA del jugador $TURNO."
                    letra_de_ia
                    echo "La IA solicita la letra $LETRA_IA."
                    comprobar_letra; fi; fi
        done
        RONDA=$((RONDA + 1))
    done
    GANADOR=0
    INDICE=1
    while test "$INDICE" -le "$JUGADORES"; do
        if test "${RONDAS_GANADAS[$INDICE]}" -gt 0; then
            if test "$GANADOR" -eq 0; then
                GANADOR="$INDICE"
            elif test "${RONDAS_GANADAS[$INDICE]}" -gt "${RONDAS_GANADAS[$GANADOR]}"; then
                GANADOR="$INDICE"
            elif test "${RONDAS_GANADAS[$INDICE]}" -eq "${RONDAS_GANADAS[$GANADOR]}" \
                -a "${VIDAS[$INDICE]}" -gt "${VIDAS[$GANADOR]}"; then
                GANADOR="$INDICE"; fi; fi
        INDICE=$((INDICE + 1))
    done
    if test "$GANADOR" -eq 0; then
        echo "La partida termina sin ganador: todas las rondas fueron desiertas."
    else
        echo "Ganador de la partida: jugador $GANADOR."; fi
    echo "Rondas ganadas:"
    INDICE=1
    while test "$INDICE" -le "$JUGADORES"; do
        echo "Jugador $INDICE: ${RONDAS_GANADAS[$INDICE]}"
        INDICE=$((INDICE + 1))
    done
    TIEMPO="$SECONDS"
    registrar_partida
}
function calcular_media {
    if test "$2" -eq 0; then
        RESULTADO="0.00"
    else
        CENTESIMAS=$((100 * $1 / $2))
        RESULTADO="$((CENTESIMAS / 100)).$((CENTESIMAS % 100))"
        if test "${RESULTADO#*.}" -lt 10; then
            RESULTADO="${RESULTADO%.*}.0${RESULTADO#*.}"; fi; fi
}
function ver_estadisticas {
    buscar_ruta_log
    if test ! -f "$ARCHIVO_LOG" -o ! -r "$ARCHIVO_LOG"; then
        echo "Todavía no hay partidas registradas."
        return; fi
    TOTAL_PARTIDAS=0
    TIEMPO_TOTAL=0
    RONDAS_TOTAL=0
    LETRAS_TOTAL=0
    PARTIDAS_SIN_GANADOR=0
    TIEMPO_MINIMO=0
    TIEMPO_MAXIMO=0
    FECHA_MINIMA=""
    HORA_MINIMA=""
    FECHA_MAXIMA=""
    HORA_MAXIMA=""
    PARTIDAS_GANADAS=()
    PARTIDAS_JUGADAS=()
    VECES_ESTRATEGIA=()
    VECES_CATEGORIA=()
    for INDICE in 0 1 2 3 4; do
        PARTIDAS_GANADAS[$INDICE]=0
        PARTIDAS_JUGADAS[$INDICE]=0
        VECES_CATEGORIA[$INDICE]=0
    done
    for INDICE in 0 1 2; do
        VECES_ESTRATEGIA[$INDICE]=0
    done
    while IFS='|' read -r FECHA HORA TPO NUM_JUGADORES NUM_RONDAS_LOG VIDA_LOG PFALLO_LOG PRESPUESTA_LOG CATEGORIA ESTRATEGIA_LOG GANADOR_LOG RONDAS_J1 RONDAS_J2 RONDAS_J3 RONDAS_J4 LETRAS_LOG FRASES_LOG; do
        FRASES_LOG="${FRASES_LOG%$'\r'}"
        if test "$FECHA" != "FECHA" -a -n "$FECHA"; then
            REGISTRO_VALIDO=1
            for NUMERO in "$TPO" "$NUM_JUGADORES" "$NUM_RONDAS_LOG" "$VIDA_LOG" "$PFALLO_LOG" "$PRESPUESTA_LOG" "$CATEGORIA" "$ESTRATEGIA_LOG" "$GANADOR_LOG" "$LETRAS_LOG" "$FRASES_LOG"; do
                if ! entero "$NUMERO"
                then REGISTRO_VALIDO=0; fi
            done
            if test "$REGISTRO_VALIDO" -eq 1; then
                if test "$NUM_JUGADORES" -lt 2 -o "$NUM_JUGADORES" -gt 4 -o "$NUM_RONDAS_LOG" -lt 1 \
                    -o "$VIDA_LOG" -lt 50 -o "$VIDA_LOG" -gt 100 -o "$PFALLO_LOG" -lt 5 -o "$PFALLO_LOG" -gt 10 \
                    -o "$PRESPUESTA_LOG" -le "$PFALLO_LOG" -o "$PRESPUESTA_LOG" -ge "$VIDA_LOG" -o "$CATEGORIA" -lt 1 -o "$CATEGORIA" -gt 4 \
                    -o "$ESTRATEGIA_LOG" -lt 0 -o "$ESTRATEGIA_LOG" -gt 2 -o "$GANADOR_LOG" -gt "$NUM_JUGADORES"
                then REGISTRO_VALIDO=0; fi; fi
            if test "$REGISTRO_VALIDO" -eq 1; then
                RONDAS_LOG=("" "$RONDAS_J1" "$RONDAS_J2" "$RONDAS_J3" "$RONDAS_J4")
                for INDICE in 1 2 3 4; do
                    if test "$INDICE" -le "$NUM_JUGADORES"; then
                        if ! entero "${RONDAS_LOG[$INDICE]}"
                        then REGISTRO_VALIDO=0
                        elif test "${RONDAS_LOG[$INDICE]}" -gt "$NUM_RONDAS_LOG"
                        then REGISTRO_VALIDO=0; fi
                    elif test "${RONDAS_LOG[$INDICE]}" != "-"
                    then REGISTRO_VALIDO=0; fi
                done; fi
            if test "$REGISTRO_VALIDO" -eq 1; then
                TOTAL_PARTIDAS=$((TOTAL_PARTIDAS + 1))
                TIEMPO_TOTAL=$((TIEMPO_TOTAL + TPO))
                RONDAS_TOTAL=$((RONDAS_TOTAL + NUM_RONDAS_LOG))
                LETRAS_TOTAL=$((LETRAS_TOTAL + LETRAS_LOG))
                VECES_ESTRATEGIA[$ESTRATEGIA_LOG]=$((VECES_ESTRATEGIA[$ESTRATEGIA_LOG] + 1))
                VECES_CATEGORIA[$CATEGORIA]=$((VECES_CATEGORIA[$CATEGORIA] + 1))
                if test "$GANADOR_LOG" -eq 0
                then PARTIDAS_SIN_GANADOR=$((PARTIDAS_SIN_GANADOR + 1))
                else PARTIDAS_GANADAS[$GANADOR_LOG]=$((PARTIDAS_GANADAS[$GANADOR_LOG] + 1)); fi
                for INDICE in 1 2 3 4; do
                    if test "$INDICE" -le "$NUM_JUGADORES"; then
                        PARTIDAS_JUGADAS[$INDICE]=$((PARTIDAS_JUGADAS[$INDICE] + 1)); fi
                done
                if test "$TOTAL_PARTIDAS" -eq 1; then
                    TIEMPO_MINIMO="$TPO"; TIEMPO_MAXIMO="$TPO"
                    FECHA_MINIMA="$FECHA"; HORA_MINIMA="$HORA"
                    FECHA_MAXIMA="$FECHA"; HORA_MAXIMA="$HORA"
                else
                    if test "$TPO" -lt "$TIEMPO_MINIMO"
                    then TIEMPO_MINIMO="$TPO"; FECHA_MINIMA="$FECHA"; HORA_MINIMA="$HORA"; fi
                    if test "$TPO" -gt "$TIEMPO_MAXIMO"
                    then TIEMPO_MAXIMO="$TPO"; FECHA_MAXIMA="$FECHA"; HORA_MAXIMA="$HORA"; fi; fi; fi; fi
    done < "$ARCHIVO_LOG"
    if test "$TOTAL_PARTIDAS" -eq 0; then
        echo "Todavía no hay partidas registradas."
        return; fi
    calcular_media "$TIEMPO_TOTAL" "$TOTAL_PARTIDAS"; MEDIA_TIEMPO="$RESULTADO"
    calcular_media "$RONDAS_TOTAL" "$TOTAL_PARTIDAS"; MEDIA_RONDAS="$RESULTADO"
    calcular_media "$LETRAS_TOTAL" "$TOTAL_PARTIDAS"; MEDIA_LETRAS="$RESULTADO"
    calcular_media "$((PARTIDAS_SIN_GANADOR * 100))" "$TOTAL_PARTIDAS"; PORCENTAJE_SIN_GANADOR="$RESULTADO"
    echo "ESTADÍSTICAS"
    echo "Partidas jugadas: $TOTAL_PARTIDAS"
    echo "Tiempo medio: $MEDIA_TIEMPO segundos"
    echo "Partida más corta: $FECHA_MINIMA $HORA_MINIMA, $TIEMPO_MINIMO segundos"
    echo "Partida más larga: $FECHA_MAXIMA $HORA_MAXIMA, $TIEMPO_MAXIMO segundos"
    echo "Rendimiento por jugador:"
    for INDICE in 1 2 3 4; do
        if test "${PARTIDAS_JUGADAS[$INDICE]}" -gt 0; then
            calcular_media "$((PARTIDAS_GANADAS[$INDICE] * 100))" "${PARTIDAS_JUGADAS[$INDICE]}"
            echo "Jugador $INDICE: ${PARTIDAS_GANADAS[$INDICE]} partidas ganadas, $RESULTADO% de sus partidas jugadas"
        else
            echo "Jugador $INDICE: no ha participado"; fi
    done
    echo "Promedio de rondas por partida: $MEDIA_RONDAS"
    MAYOR_USO=0
    for INDICE in 0 1 2; do
        if test "${VECES_ESTRATEGIA[$INDICE]}" -gt "$MAYOR_USO"
        then MAYOR_USO="${VECES_ESTRATEGIA[$INDICE]}"; fi
    done
    echo -n "Estrategia de IA más utilizada:"
    for INDICE in 0 1 2; do
        if test "${VECES_ESTRATEGIA[$INDICE]}" -eq "$MAYOR_USO"; then
            case "$INDICE" in
                0) echo -n " 0 (alfabética)" ;;
                1) echo -n " 1 (aleatoria)" ;;
                2) echo -n " 2 (propia)" ;; esac; fi
    done
    echo
    MAYOR_USO=0
    for INDICE in 1 2 3 4; do
        if test "${VECES_CATEGORIA[$INDICE]}" -gt "$MAYOR_USO"
        then MAYOR_USO="${VECES_CATEGORIA[$INDICE]}"; fi
    done
    echo -n "Nivel de categorías más utilizado:"
    for INDICE in 1 2 3 4; do
        if test "${VECES_CATEGORIA[$INDICE]}" -eq "$MAYOR_USO"
        then
            case "$INDICE" in
                1) echo -n " 1 (refranes)" ;;
                2) echo -n " 2 (refranes y películas)" ;;
                3) echo -n " 3 (refranes, películas y música)" ;;
                4) echo -n " 4 (todas las categorías)" ;; esac; fi
    done
    echo
    echo "Promedio de letras utilizadas: $MEDIA_LETRAS"
    echo "Estadística libre: partidas sin ganador, $PARTIDAS_SIN_GANADOR de $TOTAL_PARTIDAS ($PORCENTAJE_SIN_GANADOR%)."
}
function buscar_ruta_log {
    case "$RUTA_LOG" in
        /*) ARCHIVO_LOG="$RUTA_LOG" ;;
        *) ARCHIVO_LOG="$CARPETA/$RUTA_LOG" ;; esac
}
iniciar "$@"
