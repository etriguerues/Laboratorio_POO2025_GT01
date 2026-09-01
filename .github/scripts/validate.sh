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
import java.util.Arrays;
import java.lang.reflect.Field;

public class TestRunner {
    public static void main(String[] args) {
        boolean allTestsPassed = true;

        // Prueba 1: Verificar la clase Estudiante (Constructor, Getters y agregarNota)
        try {
            Estudiante est = new Estudiante("Juan Perez", "JP2025");
            est.agregarNota(8.5);
            est.agregarNota(9.5);
            if (!est.getNombre().equals("Juan Perez") || !est.getCarnet().equals("JP2025") || est.getNotas().size() != 2) {
                System.out.println("❌ TEST 1 FALLIDO: La clase Estudiante (constructor, getters o agregarNota) no funciona como se esperaba.");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 1 APROBADO: La clase Estudiante (constructor y getters) funciona correctamente.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 1 FALLIDO: Error crítico al usar la clase Estudiante. " + e.getMessage());
            allTestsPassed = false;
        }

        // Prueba 1.5: Verificar Setters obligatorios
        try {
            Estudiante est = new Estudiante("Temporal", "T00");
            est.setNombre("Nuevo Nombre");
            est.setCarnet("N123");
            est.setNotas(new ArrayList<>(Arrays.asList(10.0, 9.0)));
            if (!est.getNombre().equals("Nuevo Nombre") || !est.getCarnet().equals("N123") || est.getNotas().size() != 2) {
                System.out.println("❌ TEST 1.5 FALLIDO: Los setters requeridos (setNombre, setCarnet, setNotas) no funcionan correctamente.");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 1.5 APROBADO: Los métodos setters de la clase Estudiante existen y funcionan.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 1.5 FALLIDO: Faltan los métodos setters o causaron error. " + e.getMessage());
            allTestsPassed = false;
        }

        // Prueba 2: Verificar constante NOTA_MINIMA en ServicioEvaluacion
        try {
            Field field = ServicioEvaluacion.class.getDeclaredField("NOTA_MINIMA");
            field.setAccessible(true);
            double val = field.getDouble(new ServicioEvaluacion());
            if (val != 6.0) {
                System.out.println("❌ TEST 2 FALLIDO: La constante NOTA_MINIMA existe, pero no tiene el valor de 6.0.");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 2 APROBADO: La constante NOTA_MINIMA = 6.0 está definida correctamente.");
            }
        } catch (NoSuchFieldException e) {
            System.out.println("❌ TEST 2 FALLIDO: No se encontró el atributo 'NOTA_MINIMA' en ServicioEvaluacion.");
            allTestsPassed = false;
        } catch (Exception e) {
            System.out.println("❌ TEST 2 FALLIDO: Error al intentar acceder a la constante NOTA_MINIMA.");
            allTestsPassed = false;
        }

        // Prueba 3: Verificar ServicioEvaluacion.calcularPromedio()
        try {
            ServicioEvaluacion servicio = new ServicioEvaluacion();
            Estudiante estProm = new Estudiante("Maria Gomez", "MG2025");
            estProm.agregarNota(7.0);
            estProm.agregarNota(8.0);
            estProm.agregarNota(9.0);
            double promedio = servicio.calcularPromedio(estProm);
            if (Math.abs(promedio - 8.0) > 0.001) {
                System.out.println("❌ TEST 3 FALLIDO: El método calcularPromedio() no devuelve el valor esperado (8.0).");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 3 APROBADO: El método calcularPromedio() calcula adecuadamente.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 3 FALLIDO: Error en calcularPromedio(). " + e.getMessage());
            allTestsPassed = false;
        }

        // Prueba 4: Verificar ServicioEvaluacion.obtenerEstado() - Caso "Aprobado"
        try {
            ServicioEvaluacion servicio = new ServicioEvaluacion();
            Estudiante estAprobado = new Estudiante("Carlos Diaz", "CD2025");
            estAprobado.agregarNota(6.0);
            estAprobado.agregarNota(6.0);
            String estado = servicio.obtenerEstado(estAprobado);
            if (!"Aprobado".equals(estado)) {
                System.out.println("❌ TEST 4 FALLIDO: Un estudiante con promedio 6.0 debería estar 'Aprobado'.");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 4 APROBADO: El estado 'Aprobado' se determina correctamente.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 4 FALLIDO: Error en obtenerEstado() para caso Aprobado. " + e.getMessage());
            allTestsPassed = false;
        }

        // Prueba 5: Verificar ServicioEvaluacion.obtenerEstado() - Caso "Reprobado"
        try {
            ServicioEvaluacion servicio = new ServicioEvaluacion();
            Estudiante estReprobado = new Estudiante("Ana Velez", "AV2025");
            estReprobado.agregarNota(5.9);
            estReprobado.agregarNota(5.9);
            String estado = servicio.obtenerEstado(estReprobado);
            if (!"Reprobado".equals(estado)) {
                System.out.println("❌ TEST 5 FALLIDO: Un estudiante con promedio menor a 6.0 debería estar 'Reprobado'.");
                allTestsPassed = false;
            } else {
                System.out.println("✔️ TEST 5 APROBADO: El estado 'Reprobado' se determina correctamente.");
            }
        } catch (Exception e) {
            System.out.println("❌ TEST 5 FALLIDO: Error en obtenerEstado() para caso Reprobado. " + e.getMessage());
            allTestsPassed = false;
        }

        if (!allTestsPassed) {
            System.exit(1);
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
TEST_RESULT=$?

# --- PASO 5: MOSTRAR RESULTADO FINAL ---
echo "-------------------------------------------"
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Verificación completada. Todos los tests pasaron exitosamente.${NC}"
    echo "Tu entrega ha sido recibida y procesada."
    exit 0
else
    echo -e "${RED}❌ Se encontraron errores durante la validación.${NC}"
    echo "Revisa los detalles de los tests en la salida anterior para identificar las inconsistencias."
    exit 1
fi
