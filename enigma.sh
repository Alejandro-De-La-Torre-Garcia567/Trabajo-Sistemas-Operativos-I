#!/bin/bash

# ==============================================================================
# 1. SINTAXIS DE INVOCACIÓN (enigma.sh [-g])
# ==============================================================================
if [ "$1" = "-g" ]; then
    echo "=========================================================="
    echo "            JUEGO 'EL ENIGMA' - MODO INFORMACIÓN          "
    echo "=========================================================="
    echo "Integrantes del grupo: [Nombre 1] y [Nombre 2]"
    echo "Estrategia IA propia (ESTRATEGIA=2): [Explicación aquí]"
    echo "Estadística libre: [Explicación aquí]"
    echo "=========================================================="
    exit 0
fi

# Si se introduce un argumento distinto a -g, se notifica el uso correcto
if [ $# -gt 0 ]; then
    echo "Sintaxis incorrecta. Modo correcto de uso: $0 [-g]"
    exit 1
fi

# ==============================================================================
# 2. VALIDACIÓN PREVIA OBLIGATORIA
# ==============================================================================
# Comprueba la existencia de los archivos obligatorios antes de mostrar el menú
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
    read OPCION

    case $OPCION in
        C|c)
            echo ""
            echo "--- C) CONFIGURACIÓN ---"
            echo "[Aquí meteremos el código para modificar config.cfg]"
            ;;
        J|j)
            echo ""
            echo "--- J) JUGAR ---"
            echo "[Aquí meteremos la lógica de la partida y las rondas]"
            ;;
        F|f)
            echo ""
            echo "--- F) FRASES ---"
            echo "[Aquí meteremos el código para ver y añadir frases a frases.dat]"
            ;;
        E|e)
            echo ""
            echo "--- E) ESTADÍSTICAS ---"
            echo "[Aquí meteremos el código para procesar el log]"
            ;;
        S|s)
            echo ""
            echo "Eliminando archivos temporales y devolviendo el control al sistema..."
            rm -f *.tmp
            exit 0
            ;;
        *)
            echo ""
            echo "Opción no válida. Inténtelo de nuevo."
            ;;
    esac

    echo ""
    echo "Pulse una tecla para continuar..."
    read -n 1
done
```

---

### ¿Cómo probar esta base en tu consola?

1. Guarda el archivo como `enigma.sh`.
2. Dale permisos de ejecución en la terminal[cite: 1]:
   ```bash
   chmod 755 enigma.sh