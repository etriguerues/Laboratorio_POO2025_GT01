#!/bin/bash
export LANG=C.UTF-8

# Colores para la salida en consola
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0;0m' # Sin color

echo "--------------------------------------------------------"
echo "Iniciando validación de Laboratorio 2 (OOP)..."
echo "--------------------------------------------------------"

# Variable de control de errores
FAILED=0
# BASE_PATH para Laboratorio 2
BASE_PATH="src/main/java/org/laboratorio2"

# --- PASO 1: VERIFICAR NOMBRES DE PAQUETES Y CLASES REQUERIDAS ---
echo -e "\n${YELLOW}PASO 1: Verificando la estructura completa de paquetes y clases...${NC}"

# Define aquí todos los paquetes (directorios) y clases (archivos) que son obligatorios.
REQUIRED_PATHS=(
    "$BASE_PATH/model"
    "$BASE_PATH/service"
    "$BASE_PATH/controller"
    "$BASE_PATH/model/MiembroUniversitario.java"
    "$BASE_PATH/model/Estudiante.java"
    "$BASE_PATH/service/IEstrategiaEvaluacion.java"
    "$BASE_PATH/service/EvaluacionRegular.java"
    "$BASE_PATH/service/EvaluacionPostgrado.java"
    "$BASE_PATH/controller/Main.java"
)

STRUCTURE_OK=true
for path in "${REQUIRED_PATHS[@]}"; do
    # Verifica si la ruta es un directorio (paquete)
    if [[ "$path" != *.java && ! -d "$path" ]]; then
        echo -e "${RED}❌ Paquete Requerido NO ENCONTRADO: $path${NC}"
        FAILED=1
        STRUCTURE_OK=false
    # Verifica si la ruta es un archivo (clase)
    elif [[ "$path" == *.java && ! -f "$path" ]]; then
        echo -e "${RED}❌ Clase Requerida NO ENCONTRADA: $path${NC}"
        FAILED=1
        STRUCTURE_OK=false
    fi
done

if [ "$STRUCTURE_OK" = true ]; then
    echo -e "${GREEN}✔ La estructura de paquetes y clases es correcta.${NC}"
fi

# --- PASO 2: VERIFICAR USO DE CONCEPTOS OOP ---
echo -e "\n${YELLOW}PASO 2: Verificando uso de conceptos de Programación Orientada a Objetos...${NC}"
# Si la estructura base no existe, no podemos continuar con esta verificación.
if [ ! -d "$BASE_PATH" ]; then
    echo -e "${RED}❌ No se puede continuar porque el directorio base '$BASE_PATH' no existe.${NC}"
    exit 1
fi
ALL_FILES=$(find "$BASE_PATH" -name "*.java")

# Verificar Herencia (uso de 'extends')
if ! grep -q "extends" $ALL_FILES; then
    echo -e "${RED}❌ REQUISITO FALLIDO: No se encontró uso de herencia (palabra clave 'extends').${NC}"
    FAILED=1
else
    echo -e "${GREEN}✔ Se detectó el uso de herencia ('extends').${NC}"
fi

# Verificar Interfaces (uso de 'implements')
if ! grep -q "implements" $ALL_FILES; then
    echo -e "${RED}❌ REQUISITO FALLIDO: No se encontró la implementación de interfaces (palabra clave 'implements').${NC}"
    FAILED=1
else
    echo -e "${GREEN}✔ Se detectó la implementación de interfaces ('implements').${NC}"
fi

# Verificar Clases/Métodos Abstractos (uso de 'abstract')
if ! grep -q "abstract" $ALL_FILES; then
    echo -e "${RED}❌ REQUISITO FALLIDO: No se encontró el uso de clases o métodos abstractos (palabra clave 'abstract').${NC}"
    FAILED=1
else
    echo -e "${GREEN}✔ Se detectó el uso de la palabra clave 'abstract'.${NC}"
fi

# Verificar @Override
if ! grep -q "@Override" $ALL_FILES; then
    echo -e "${RED}❌ REQUISITO FALLIDO: No se encontró el uso de la anotación '@Override'.${NC}"
    FAILED=1
else
    echo -e "${GREEN}✔ Se detectó el uso de la anotación '@Override'.${NC}"
fi

# --- PASO 3: COMPILAR TODO EL PROYECTO ---
echo -e "\n${YELLOW}PASO 3: Compilando todo el código fuente...${NC}"
mkdir -p bin
# Usamos 2>&1 para redirigir tanto la salida estándar como la de error a la variable.
# El classpath (-cp) apunta al directorio raíz del código fuente para que javac encuentre los paquetes.
COMPILE_OUTPUT=$(javac -encoding UTF-8 -cp src/main/java -d bin $(find src/main/java -name "*.java") 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ ERROR DE COMPILACIÓN. Revisa tu código:${NC}"
    # Imprime la salida del compilador para que el estudiante vea el error exacto.
    echo "$COMPILE_OUTPUT"
    FAILED=1
else
    echo -e "${GREEN}✔ Compilación exitosa.${NC}"
fi

# --- PASO 4: MOSTRAR RESULTADO FINAL ---
echo -e "\n--------------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Verificación completada exitosamente.${NC}"
    echo "El código cumple con los requisitos de estructura, OOP y compilación."
    exit 0
else
    echo -e "${RED}❌ Se encontraron errores durante la validación.${NC}"
    echo "Revisa los mensajes anteriores para corregir tu entrega."
    exit 1
fi