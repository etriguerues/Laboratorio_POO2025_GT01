#!/bin/bash
export LANG=C.UTF-8

# Colores para la salida en consola
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0;0m' # Sin color

echo "--------------------------------------------------------"
echo "Iniciando validacion Laboratorio: Monitoreo Sismico (Concurrencia)"
echo "--------------------------------------------------------"

# Variable de control de errores
FAILED=0

# --- CONFIGURACIÓN DE RUTA ---
# IMPORTANTE: Ajusta esta ruta según el 'package' que hayan usado tus estudiantes.
# Ejemplo: si el package es "com.universidad.sismos", la ruta es "src/main/java/com/universidad/sismos"
BASE_PATH="src/main/java/com/poo/lab4"

echo -e "Buscando código fuente en: $BASE_PATH"

# --- PASO 1: VERIFICAR ESTRUCTURA DE PAQUETES Y ARCHIVOS REQUERIDOS ---
echo -e "\n${YELLOW}PASO 1: Verificando la estructura de paquetes y clases...${NC}"

REQUIRED_PATHS=(
    "$BASE_PATH/model"
    "$BASE_PATH/concurrency"
    "$BASE_PATH/persistence"
    "$BASE_PATH/main"
    "$BASE_PATH/model/DatoSismico.java"
    "$BASE_PATH/concurrency/BufferSismico.java"
    "$BASE_PATH/persistence/GestorArchivos.java"
    "$BASE_PATH/main/MainSismos.java"
)

STRUCTURE_OK=true
for path in "${REQUIRED_PATHS[@]}"; do
    if [[ "$path" != *.java && ! -d "$path" ]]; then
        echo -e "${RED}[FALTA PAQUETE] No encontrado: $path${NC}"
        FAILED=1
        STRUCTURE_OK=false
    elif [[ "$path" == *.java && ! -f "$path" ]]; then
        echo -e "${RED}[FALTA CLASE] No encontrada: $path${NC}"
        FAILED=1
        STRUCTURE_OK=false
    fi
done

if [ "$STRUCTURE_OK" = true ]; then
    echo -e "${GREEN}Estructura de directorios y archivos correcta.${NC}"
fi

# --- PASO 2: VERIFICAR REQUISITOS TÉCNICOS INTERNOS ---
echo -e "\n${YELLOW}PASO 2: Verificando lógica de Concurrencia y Persistencia...${NC}"

if [ ! -d "$BASE_PATH" ]; then
    echo -e "${RED}Error fatal: El directorio base no existe. Abortando validación interna.${NC}"
    exit 1
fi

# 2.1 Validar BufferSismico (Sincronización)
BUFFER_FILE="$BASE_PATH/concurrency/BufferSismico.java"
if [ -f "$BUFFER_FILE" ]; then
    if ! grep -q "synchronized" "$BUFFER_FILE"; then
        echo -e "${RED}[ERROR] BufferSismico: No se encontró la palabra clave 'synchronized'.${NC}"
        FAILED=1
    fi
    if ! grep -q "wait()" "$BUFFER_FILE"; then
        echo -e "${RED}[ERROR] BufferSismico: No se encontró uso de 'wait()' para control de flujo.${NC}"
        FAILED=1
    fi
     if ! grep -qE "notify()|notifyAll()" "$BUFFER_FILE"; then
        echo -e "${RED}[ERROR] BufferSismico: No se encontró uso de 'notify()' o 'notifyAll()'.${NC}"
        FAILED=1
    fi
fi

# 2.2 Validar DatoSismico (Serialización)
MODEL_FILE="$BASE_PATH/model/DatoSismico.java"
if [ -f "$MODEL_FILE" ]; then
    if ! grep -q "implements Serializable" "$MODEL_FILE"; then
        echo -e "${RED}[ERROR] DatoSismico: La clase debe implementar 'Serializable'.${NC}"
        FAILED=1
    fi
fi

# 2.3 Validar GestorArchivos (Gson y IO)
GESTOR_FILE="$BASE_PATH/persistence/GestorArchivos.java"
if [ -f "$GESTOR_FILE" ]; then
    if ! grep -q "Gson" "$GESTOR_FILE"; then
        echo -e "${RED}[ERROR] GestorArchivos: No se encontró uso de la librería 'Gson'.${NC}"
        FAILED=1
    fi
    if ! grep -q "ObjectOutputStream" "$GESTOR_FILE"; then
        echo -e "${RED}[ERROR] GestorArchivos: No se encontró 'ObjectOutputStream' para serialización.${NC}"
        FAILED=1
    fi
fi

# 2.4 Validar MainSismos (ExecutorService)
MAIN_FILE="$BASE_PATH/main/MainSismos.java"
if [ -f "$MAIN_FILE" ]; then
    if ! grep -q "ExecutorService" "$MAIN_FILE"; then
        echo -e "${RED}[ERROR] MainSismos: Se requiere uso de 'ExecutorService' (Pool de hilos).${NC}"
        FAILED=1
    fi
fi

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}Validación de palabras clave (synchronized, Gson, Serializable, Executor) correcta.${NC}"
fi

# --- PASO 3: VERIFICAR MÉTODOS OBLIGATORIOS ---
echo -e "\n${YELLOW}PASO 3: Verificando implementación de métodos específicos...${NC}"
ALL_FILES=$(find "$BASE_PATH" -name "*.java")

REQUIRED_METHODS=(
    "escribirDato"      # En Buffer
    "obtenerYLimpiar"   # En Buffer
    "guardarTexto"      # En Gestor
    "guardarJSON"       # En Gestor
    "serializar"        # En Gestor
)

METHODS_OK=true
for method in "${REQUIRED_METHODS[@]}"; do
    if ! grep -q "$method" $ALL_FILES; then
        echo -e "${RED}[FALTA METODO] No se encontró la definición o llamada a: '$method'.${NC}"
        FAILED=1
        METHODS_OK=false
    fi
done

if [ "$METHODS_OK" = true ]; then
    echo -e "${GREEN}Todos los nombres de métodos requeridos fueron encontrados.${NC}"
fi

# --- PASO 4: COMPILAR PROYECTO (MAVEN) ---
echo -e "\n${YELLOW}PASO 4: Compilando con Maven (Verificando dependencias Gson)...${NC}"

# Se usa -DskipTests para agilizar, asumiendo que validamos estructura y compilación principalmente
COMPILE_OUTPUT=$(mvn clean package -DskipTests 2>&1)
MVN_EXIT_CODE=$?

if [ $MVN_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}ERROR DE COMPILACIÓN (MAVEN).${NC}"
    echo "Posibles causas: Falta dependencia Gson en pom.xml o errores de sintaxis."
    echo "---------------------------------------------------"
    echo "$COMPILE_OUTPUT" | grep -E "ERROR|FAILURE" -A 2 | head -n 10
    FAILED=1
else
    echo -e "${GREEN}Compilación Maven exitosa (BUILD SUCCESS).${NC}"
fi

# --- RESULTADO FINAL ---
echo -e "\n--------------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✔ LABORATORIO APROBADO (Estructuralmente)${NC}"
    echo "El código cumple con la estructura de paquetes, hilos, sincronización y persistencia."
    exit 0
else
    echo -e "${RED}✘ SE ENCONTRARON ERRORES${NC}"
    echo "Por favor corrige los puntos marcados en rojo arriba."
    exit 1
fi
