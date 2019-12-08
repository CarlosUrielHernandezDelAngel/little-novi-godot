# Sistema de Slots de Guardado Mejorado - Guía de Uso

## 📋 Descripción General

Este sistema proporciona un gestor completo de slots de guardado (3 ranuras) con:

- **Captura automática de pantalla** como miniatura (200x150 px)
- **Almacenamiento de datos** en JSON (capítulo, diálogos, puzzles)
- **Registro de fecha/hora** del guardado
- **Visualización en tiempo real** en la interfaz gráfica

## Archivos Generados

### Por cada slot se crean 2 archivos:

```
user://slot1.json   (datos del progreso)
user://slot1.png    (miniatura de la escena)

user://slot2.json
user://slot2.png

user://slot3.json
user://slot3.png
```

### Estructura del JSON

```json
{
  "numero_slot": 1,
  "capitulo_actual": 3,
  "indice_dialogo": 15,
  "estado_puzzles": {
    "puzzle_1": { "completado": true, "intentos": 2 },
    "puzzle_2": { "completado": false, "intentos": 5 },
    "puzzle_3": { "completado": true, "intentos": 1 }
  },
  "timestamp": 1716458400000
}
```

---

## Cómo Usar el Sistema

### 1. **Cargar la Escena de Slots**

```gdscript
# En el menú principal, cargar la escena de slots
get_tree().change_scene_to_file("res://menu/slots.tscn")
```

### 2. **Guardar el Progreso en un Slot**

```gdscript
# Obtener referencia al script de slots
var slots_manager = get_tree().root.get_node("slots")

# Actualizar el progreso actual
slots_manager.actualizar_progreso_actual({
	"capitulo_actual": 5,
	"indice_dialogo": 42,
	"estado_puzzles": {
		"puzzle_1": {"completado": true, "intentos": 3},
		"puzzle_2": {"completado": false, "intentos": 0},
		"puzzle_3": {"completado": true, "intentos": 1}
	}
})

# Guardar en el slot seleccionado
var numero_slot = slots_manager.obtener_slot_seleccionado()
var guardado_exitoso = slots_manager.guardar_progreso_en_slot(numero_slot)

if guardado_exitoso:
	print("✓ Progreso guardado en Slot %d" % numero_slot)
else:
	print("❌ Error al guardar")
```

### 3. **Cargar un Slot Específico**

```gdscript
var slots_manager = get_tree().root.get_node("slots")

# Cargar datos del slot 2
var progreso = slots_manager.cargar_progreso_de_slot(2)

if not progreso.is_empty():
	print("Capítulo: %d" % progreso.capitulo_actual)
	print("Diálogo: %d" % progreso.indice_dialogo)
	print("Puzzles: %s" % progreso.estado_puzzles)
else:
	print("El slot 2 está vacío")
```

### 4. **Obtener Información de Todos los Slots**

```gdscript
var slots_manager = get_tree().root.get_node("slots")

var info = slots_manager.obtener_informacion_todos_slots()

for slot_info in info:
	if slot_info["ocupado"]:
		print("Slot %d - Cap. %d | Diálogo %d | %s" % [
			slot_info["numero"],
			slot_info["capitulo"],
			slot_info["dialogo"],
			slot_info["fecha"]
		])
	else:
		print("Slot %d - VACÍO" % slot_info["numero"])
```

### 5. **Eliminar un Slot**

```gdscript
var slots_manager = get_tree().root.get_node("slots")

# Eliminar completamente el slot 1 (JSON y PNG)
var eliminado = slots_manager.eliminar_slot(1)

if eliminado:
	print("✓ Slot 1 eliminado")
```

---

## 🔧 Funciones Públicas Disponibles

| Función                                         | Descripción                                         | Retorna      |
| ----------------------------------------------- | --------------------------------------------------- | ------------ |
| `guardar_progreso_en_slot(numero_slot: int)`    | Guarda progreso + miniatura en el slot especificado | `bool`       |
| `cargar_progreso_de_slot(numero_slot: int)`     | Carga datos del slot                                | `Dictionary` |
| `actualizar_informacion_todos_slots()`          | Actualiza visualización UI de todos los slots       | `void`       |
| `obtener_informacion_todos_slots()`             | Obtiene array con info de todos los slots           | `Array`      |
| `eliminar_slot(numero_slot: int)`               | Borra completamente un slot (JSON + PNG)            | `bool`       |
| `obtener_progreso_actual()`                     | Obtiene progreso en memoria                         | `Dictionary` |
| `actualizar_progreso_actual(datos: Dictionary)` | Actualiza progreso en memoria                       | `void`       |
| `obtener_slot_seleccionado()`                   | Obtiene número del slot seleccionado                | `int`        |

---

## Captura de Pantalla Automática

Cuando llamas a `guardar_progreso_en_slot()`, el sistema automáticamente:

1.  Captura la pantalla actual
2.  Redimensiona a 200x150 píxeles
3.  Guarda como PNG en `user://slot[N].png`
4.  Actualiza la visualización en la UI

**Nota:** La miniatura se toma del viewport en el momento del guardado.

---

## 🕐 Formato de Fecha/Hora

Las fechas se almacenan como timestamp UNIX (milisegundos) y se convierten a:

```
DD/MM/YYYY - HH:MM:SS
Ejemplo: 2026/06/04 - 15:30:45
```

---

## 📝 Ejemplo Completo: Guardar y Cargar

```gdscript
extends Node

func _ready():
	# Obtener referencia al gestor de slots
	var slots = get_tree().root.get_node("Control")  # La escena raíz de slots.tscn

	# Simular selección de slot 1
	slots._on_slot_pressed(1)

	# Preparar datos de progreso
	var progreso = {
		"capitulo_actual": 2,
		"indice_dialogo": 10,
		"estado_puzzles": {
			"puzzle_1": {"completado": true, "intentos": 1},
			"puzzle_2": {"completado": false, "intentos": 0},
			"puzzle_3": {"completado": false, "intentos": 2}
		}
	}

	# Actualizar y guardar
	slots.actualizar_progreso_actual(progreso)

	if slots.guardar_progreso_en_slot(1):
		print("✓ Guardado en Slot 1")

		# Más tarde, cargar el slot
		var datos_cargados = slots.cargar_progreso_de_slot(1)
		print("Capítulo cargado: %d" % datos_cargados.capitulo_actual)
```

---

## ⚙️ Configuración Personalizable

En `menu/slots.gd`, puedes modificar estas constantes:

```gdscript
const NUMERO_SLOTS = 3                    # Cambiar cantidad de slots
const TAMAÑO_MINIATURA = Vector2(200, 150) # Cambiar tamaño de miniatura
const RUTA_BASE = "user://"               # Cambiar ubicación (no recomendado)
```

---

## 🐛 Troubleshooting

### ❌ "El archivo del Slot está vacío"

- El slot aún no ha sido guardado
- Usa `obtener_informacion_todos_slots()` para verificar

### ❌ "No se pudo capturar la pantalla"

- El viewport puede no estar disponible en el momento del guardado
- Intenta guardar después de esperar 1 frame con `await get_tree().process_frame`

### ❌ Las miniaturas no aparecen

- Verifica que la ruta `user://` sea accesible
- Revisa los errores en la consola de Godot
- Asegúrate que el TextureRect esté configurado correctamente en la escena

---

## 📊 Estructura de Directorios Esperada

```
proyecto/
├── menu/
│   ├── slots.tscn          ← Escena de slots
│   └── slots.gd            ← Script del gestor
├── user://                 ← Carpeta de datos guardados
│   ├── slot1.json
│   ├── slot1.png
│   ├── slot2.json
│   ├── slot2.png
│   ├── slot3.json
│   └── slot3.png
```

---

## ✨ Características Principales

- ✅ **3 Slots independientes** con datos completos
- ✅ **Captura automática** de pantalla cada vez que se guarda
- ✅ **Fecha/Hora precisa** de cada guardado
- ✅ **Validación de datos** para evitar corrupción
- ✅ **UI actualizada en tiempo real**
- ✅ **Soporte para puzzles** y estado de progreso
- ✅ **Comentarios en español** en todo el código
- ✅ **Funciones públicas limpias** y bien documentadas

---

## 🎯 Casos de Uso

1. **Guardar automático:** Después de cada capítulo completado
2. **Guardar manual:** Desde un menú dentro del juego
3. **Cargar automático:** Al iniciar el juego
4. **Mostrar slots:** En pantalla de selección de guardado

¡El sistema está listo para usar! 🚀
