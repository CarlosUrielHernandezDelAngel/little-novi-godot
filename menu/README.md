# 📦 Sistema de Slots de Guardado - Menu

Este directorio contiene la interfaz gráfica y el gestor del sistema de guardado de 3 slots.

## 📄 Archivos Principales

### `slots.tscn`

**Escena Godot 4** que define la interfaz visual del sistema de slots.

- **Nodo Raíz:** `Control`
- **Estructura:**
  - `TextureRect` (fondo)
  - `Panel` (contenedor decorativo con título)
  - `VBoxContainer` (contenedor principal con 3 slots)
    - `slot1_container` → TextureRect (miniatura) + VBoxContainer (Label + Button)
    - `slot2_container` → TextureRect (miniatura) + VBoxContainer (Label + Button)
    - `slot3_container` → TextureRect (miniatura) + VBoxContainer (Label + Button)

### `slots.gd`

**Script GDScript** que gestiona toda la lógica del sistema de guardado.

**Características:**

- ✅ Guarda datos en JSON (`user://slot[N].json`)
- ✅ Captura pantalla como miniatura PNG (`user://slot[N].png`)
- ✅ Almacena fecha/hora de guardado
- ✅ Carga y visualiza miniaturas en la UI
- ✅ Validación de datos integrada
- ✅ Comentarios en español

---

## 🎮 Uso Rápido

### 1. Cargar la escena en el juego

```gdscript
get_tree().change_scene_to_file("res://menu/slots.tscn")
```

### 2. Guardar progreso

```gdscript
var slots = get_tree().root.get_node("Control")
slots.actualizar_progreso_actual({
	"capitulo_actual": 3,
	"indice_dialogo": 42,
	"estado_puzzles": {
		"puzzle_1": {"completado": true, "intentos": 2},
		"puzzle_2": {"completado": false, "intentos": 0},
		"puzzle_3": {"completado": false, "intentos": 1}
	}
})
slots.guardar_progreso_en_slot(1)
```

### 3. Cargar progreso

```gdscript
var slots = get_tree().root.get_node("Control")
var progreso = slots.cargar_progreso_de_slot(1)
print("Capítulo: %d" % progreso.capitulo_actual)
```

---

## 📚 Documentación Completa

Ver `SISTEMA_SLOTS_GUIA.md` en la raíz del proyecto para:

- Guía detallada de todas las funciones
- Ejemplos de integración
- Troubleshooting
- Configuración personalizada

---

## 📁 Archivos Generados

Al usar el sistema, se crean automáticamente en `user://`:

```
user://slot1.json   → Datos del jugador
user://slot1.png    → Miniatura (200x150)
user://slot2.json
user://slot2.png
user://slot3.json
user://slot3.png
```

---

## 🔧 Funciones Públicas Clave

| Función                             | Parámetros          | Retorna      |
| ----------------------------------- | ------------------- | ------------ |
| `guardar_progreso_en_slot()`        | `numero_slot: int`  | `bool`       |
| `cargar_progreso_de_slot()`         | `numero_slot: int`  | `Dictionary` |
| `actualizar_progreso_actual()`      | `datos: Dictionary` | `void`       |
| `obtener_informacion_todos_slots()` | —                   | `Array`      |
| `eliminar_slot()`                   | `numero_slot: int`  | `bool`       |
| `obtener_slot_seleccionado()`       | —                   | `int`        |

---

## ✨ Características

- 📸 Captura automática de pantalla cada vez que se guarda
- 🕐 Registro de fecha/hora con formato legible
- 💾 Almacenamiento en JSON estructurado
- 🎨 Visualización de miniaturas en la UI
- ✅ Validación de integridad de datos
- 📝 Comentarios en español en todo el código
- 🔄 Soporte para capítulos, diálogos y puzzles

---

## 🚀 Ejemplo de Integración Completa

Ver `scripts/ejemplo_integracion_slots.gd` para un ejemplo detallado que muestra:

- Cómo guardar después de completar diálogos
- Cómo cargar un slot y restaurar el estado
- Cómo actualizar el estado de puzzles
- Funciones de debug y prueba

---

## ⚙️ Configuración Personalizable

En `slots.gd`, puedes modificar:

```gdscript
const NUMERO_SLOTS = 3                    # Cambiar cantidad de slots
const TAMAÑO_MINIATURA = Vector2(200, 150) # Tamaño de miniatura
const RUTA_BASE = "user://"               # Ubicación de archivos
```

---

## 📖 Estructura del JSON Guardado

```json
{
  "numero_slot": 1,
  "capitulo_actual": 5,
  "indice_dialogo": 42,
  "estado_puzzles": {
    "puzzle_1": { "completado": true, "intentos": 3 },
    "puzzle_2": { "completado": false, "intentos": 1 },
    "puzzle_3": { "completado": true, "intentos": 2 }
  },
  "timestamp": 1716458400000
}
```

---

¡Sistema listo para usar! 🎉
