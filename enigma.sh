#!/bin/bash

# ==============================================================================
# 1. SINTAXIS DE INVOCACIÓN (enigma.sh [-g])
# ==============================================================================
if [ "$1" = "-g" ]; then
    echo "=========================================================="
    echo "            JUEGO 'EL ENIGMA' - MODO INFORMACIÓN          "
    echo "=========================================================="
    echo "Integrantes del grupo: [Nombre 1] y [Nombre 2]"
    echo "Estrategia IA propia (ESTRATEGIA=2): Frecuencia de letras."
    echo "Estadística libre: Porcentaje de rondas desiertas globales."
    echo "=========================================================="
    exit 0
fi

if [ $# -gt 0 ]; then
    echo "Sintaxis incorrecta. Modo correcto de uso: $0 [-g]"
    exit 1
fi

# ==============================================================================
# 2. VALIDACIÓN PREVIA OBLIGATORIA
# ==============================================================================
if [ ! -f "config.cfg" ] || [ ! -f "frases.dat" ]; then
    echo "Error: Los archivos 'config.cfg' o 'frases.dat' no existen o no son válidos."
    exit 1
fi

# ==============================================================================
# 3. BUCLE DEL MENÚ PRINCIPAL
# ==============================================================================
OPCION=""

while [ "$OPCION" != "S" ] && [ "$OPCION" != "s" ]; do
    clear
    echo "JUEGO \"EL ENIGMA\""
    echo "C) CONFIGURACIÓN"
    echo "J) JUGAR"
    echo "F) FRASES"
    echo "E) ESTADÍSTICAS"
    echo "S) SALIR"
    echo -n "Introduzca una opción >> "
    read -r OPCION

    case $OPCION in
        C|c)
            echo ""
            echo "--- C) CONFIGURACIÓN ---"
            echo "[Próximamente: Modificar config.cfg]"
            ;;
        J|j)
            echo ""
            echo "--- J) JUGAR ---"
            echo "[Próximamente: Motor de juego]"
            ;;
        F|f)
            echo ""
            echo "--- F) GESTIÓN DE FRASES ---"
            echo "1. Consultar frases"
            echo "2. Añadir nueva frase"
            echo -n "Seleccione una opción (1 o 2) >> "
            read -r OPCION_FRASES

            if [ "$OPCION_FRASES" = "1" ]; then
                echo ""
                echo "Listado de frases disponibles:"
                echo "-------------------------------"
                cat frases.dat
                echo "-------------------------------"
            elif [ "$OPCION_FRASES" = "2" ]; then
                echo ""
                echo -n "Introduzca la categoría (REFRAN, PELICULA, MUSICA, DEPORTE) >> "
                read -r NUEVA_CAT
                echo -n "Introduzca la nueva frase >> "
                read -r NUEVA_FRASE

                # Pasamos ambos textos a mayúsculas
                NUEVA_CAT_MAYUS=$(echo "$NUEVA_CAT" | tr '[:lower:]' '[:upper:]')
                NUEVA_FRASE_MAYUS=$(echo "$NUEVA_FRASE" | tr '[:lower:]' '[:upper:]')

                # Guardamos la frase en el archivo
                echo "${NUEVA_CAT_MAYUS}:${NUEVA_FRASE_MAYUS}" >> frases.dat
                echo "Frase añadida correctamente."
            else
                echo "Opción incorrecta."
            fi
            ;;
        E|e)
            echo ""
            echo "--- E) ESTADÍSTICAS ---"
            echo "[Próximamente: Procesar log]"
            ;;
        S|s)
            echo ""
            echo "Eliminando archivos temporales..."
            rm -f ./*.tmp 2>/dev/null
            exit 0
            ;;
        *)
            echo ""
            echo "Opción no válida. Inténtelo de nuevo."
            ;;
    esac

    echo ""
    echo "Pulse una tecla para continuar..."
    read -r -n 1
done