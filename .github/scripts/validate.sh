#!/bin/bash

# Colores para la salida en consola
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0;0m' # Sin color

echo "-------------------------------------------"
echo "🚀 Iniciando validación de Laboratorio..."
echo "-------------------------------------------"

# --- PASO 1: VERIFICAR LA ESTRUCTURA DE ARCHIVOS REQUERIDA ---
echo "✅ PASO 1: Verificando estructura de archivos..."
BASE_PATH="src/main/java/org/laboratorio1"
ESTUDIANTE_FILE="$BASE_PATH/model/Estudiante.java"
SERVICIO_FILE="$BASE_PATH/service/ServicioEvaluacion.java"
MAIN_FILE="$BASE_PATH/controller/Main.java"

if [ ! -f "$ESTUDIANTE_FILE" ] || [ ! -f "$SERVICIO_FILE" ] || [ ! -f "$MAIN_FILE" ]; then
    echo -e "${RED}❌ ERROR: Estructura de archivos incorrecta.${NC}"
    echo "Asegúrate de que existan los siguientes archivos en sus paquetes correctos:"
    [ ! -f "$ESTUDIANTE_FILE" ] && echo "  - Falta: $ESTUDIANTE_FILE"
    [ ! -f "$SERVICIO_FILE" ] && echo "  - Falta: $SERVICIO_FILE"
    [ ! -f "$MAIN_FILE" ] && echo "  - Falta: $MAIN_FILE"
    exit 1
fi
echo -e "${GREEN}Estructura de archivos correcta.${NC}"


# --- PASO 2: CREAR EL TEST RUNNER PARA VALIDAR LA LÓGICA ---
echo "✅ PASO 2: Creando el entorno de pruebas..."
cat <<EOF > TestRunner.java
import org.laboratorio1.model.Estudiante;
import org.laboratorio1.service.ServicioEvaluacion;
import java.util.ArrayList;
import java.util.List;

public class TestRunner {
    public static void main(String[] args) {
        boolean allTestsPassed = true;

        // Prueba 1: Verificar la clase Estudiante
        try {
            Estudiante est = new Estudiante("Juan Perez", "JP2025");
            est.agregarNota(8.5);
            est.agregarNota(9.5);
            if (!est.getNombre().equals("Juan Perez") || !est.getCarnet().equals("JP2025") || est.getNotas().size() != 2) {
                System.out.println("❌ TEST 1 FALLIDO: La clase Estudiante (constructor, getters o agregarNota) no funciona como se esperaba.");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 1 APROBADO: La clase Estudiante funciona correctamente.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 1 FALLIDO: Error crítico al usar la clase Estudiante. " + e.getMessage());
            allTestsPassed = false;
        }

        // Prueba 2: Verificar ServicioEvaluacion.calcularPromedio()
        try {
            ServicioEvaluacion servicio = new ServicioEvaluacion();
            Estudiante estProm = new Estudiante("Maria Gomez", "MG2025");
            estProm.agregarNota(7.0);
            estProm.agregarNota(8.0);
            estProm.agregarNota(9.0);
            double promedio = servicio.calcularPromedio(estProm);
            if (Math.abs(promedio - 8.0) > 0.001) { // Comparar doubles con un margen de error
                System.out.println("❌ TEST 2 FALLIDO: El método calcularPromedio() no devuelve el valor esperado (8.0).");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 2 APROBADO: El método calcularPromedio() funciona correctamente.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 2 FALLIDO: Error en calcularPromedio(). " + e.getMessage());
            allTestsPassed = false;
        }

        // Prueba 3: Verificar ServicioEvaluacion.obtenerEstado() - Caso "Aprobado"
        try {
            ServicioEvaluacion servicio = new ServicioEvaluacion();
            Estudiante estAprobado = new Estudiante("Carlos Diaz", "CD2025");
            estAprobado.agregarNota(6.0);
            estAprobado.agregarNota(6.0); // Promedio exacto de 6.0
            String estado = servicio.obtenerEstado(estAprobado);
            if (!"Aprobado".equals(estado)) {
                System.out.println("❌ TEST 3 FALLIDO: Un estudiante con promedio 6.0 debería estar 'Aprobado'.");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 3 APROBADO: El estado 'Aprobado' se determina correctamente.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 3 FALLIDO: Error en obtenerEstado() para caso Aprobado. " + e.getMessage());
            allTestsPassed = false;
        }

        // Prueba 4: Verificar ServicioEvaluacion.obtenerEstado() - Caso "Reprobado"
        try {
            ServicioEvaluacion servicio = new ServicioEvaluacion();
            Estudiante estReprobado = new Estudiante("Ana Velez", "AV2025");
            estReprobado.agregarNota(5.9);
            estReprobado.agregarNota(5.9); // Promedio menor a 6.0
            String estado = servicio.obtenerEstado(estReprobado);
            if (!"Reprobado".equals(estado)) {
                System.out.println("❌ TEST 4 FALLIDO: Un estudiante con promedio menor a 6.0 debería estar 'Reprobado'.");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 4 APROBADO: El estado 'Reprobado' se determina correctamente.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 4 FALLIDO: Error en obtenerEstado() para caso Reprobado. " + e.getMessage());
            allTestsPassed = false;
        }

        if (!allTestsPassed) {
            System.exit(1); // Salir con código de error si alguna prueba falló
        }
    }
}
EOF
echo -e "${GREEN}Entorno de pruebas creado.${NC}"

# --- PASO 3: COMPILAR TODO EL PROYECTO ---
echo "✅ PASO 3: Compilando todo el código fuente..."
mkdir -p bin
COMPILE_OUTPUT=$(javac -encoding UTF-8 -d bin $(find . -name "*.java") 2>&1)
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ ERROR DE COMPILACIÓN. Revisa tu código.${NC}"
    echo "$COMPILE_OUTPUT"
    exit 1
fi
echo -e "${GREEN}Compilación exitosa.${NC}"

# --- PASO 4: EJECUTAR LAS PRUEBAS ---
echo "✅ PASO 4: Ejecutando pruebas de lógica..."
java -cp bin TestRunner
TEST_RESULT=$? # Captura el código de salida del TestRunner

# --- PASO 5: MOSTRAR RESULTADO FINAL ---
echo "-------------------------------------------"
if [ $TEST_RESULT -eq 0 ]; then
    # Mensaje de éxito, sin usar la palabra "Aprobado".
    echo -e "${GREEN}✅ Verificación completada. Todos los tests pasaron exitosamente.${NC}"
    echo "Tu entrega ha sido recibida y procesada."

    # Esencial: Mantiene el código de salida 0 para indicar éxito a GitHub Actions.
    exit 0
else
    # Mensaje de fallo que guía al alumno a revisar, sin usar la palabra "Reprobado".
    echo -e "${RED}❌ Se encontraron errores durante la validación.${NC}"
    echo "Revisa los detalles de los tests en la salida anterior para identificar las inconsistencias."

    # Esencial: Mantiene el código de salida 1 para indicar fallo a GitHub Actions.
    exit 1
fi