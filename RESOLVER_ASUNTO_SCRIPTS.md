# ✅ RESOLVER ASUNTO DE SCRIPTS - AUTOLOAD SOLUTION

## Problema

El script `cap_1.gd` NO se ejecuta porque fue reemplazado por `menu_conversacion.gd` en cap_1.tscn.

## Solución: Usar GameManager como AutoLoad

Esta es la forma CORRECTA de resolver el conflicto. Usaremos:

- **game_manager.gd** → AutoLoad (disponible globalmente)
- **cap_1.gd** → Script de cap_1.tscn (diálogos)
- **menu_conversacion.gd** → En cap_1.tscn (menú)
- **slots.gd** → Script de slots.tscn (guardado/carga)

---

## PASO 1: Configurar GameManager como AutoLoad

### 1.1 Abre Godot

- Abre tu proyecto

### 1.2 Accede a AutoLoad

```
Project → Project Settings → Autoload
```

### 1.3 Agregar Script

1. En "Node Name" escribe: `GameManager`
2. Haz clic en el ícono de carpeta
3. Selecciona: `res://scripts/game_manager.gd`
4. Presiona "Add"

**Resultado:**

```
GameManager: res://scripts/game_manager.gd ✓
```

### 1.4 Verificar

- En la consola de Godot verás: `✓ GameManager inicializado`

---

## PASO 2: Actualizar cap_1.tscn

### 2.1 Abre cap_1.tscn en editor de texto

O edita directamente en Godot:

### 2.2 Busca la línea (aprox. línea 170):

```
[node name="Cap1" type="Control" unique_id=526565439]
...
script = ExtResource("2_menu_conv")
```

### 2.3 Cambia a:

```
[node name="Cap1" type="Control" unique_id=526565439]
...
script = ExtResource("1_hb74n")
```

**Antes:** `script = ExtResource("2_menu_conv")` ← menu_conversacion.gd
**Después:** `script = ExtResource("1_hb74n")` ← cap_1.gd

---

## PASO 3: Actualizar Scripts

### 3.1 Modificar cap_1.gd

Agregar al FINAL del archivo `cap_1.gd`:

```gdscript
# ─── Conectar con GameManager
func _ready() -> void:
	# Código original
	$Dialogos/Bochi.iniciar()

	# Conectar con GameManager
	GameManager.progreso_actualizado.connect(_on_progreso_actualizado)

func _on_progreso_actualizado() -> void:
	"""
	Se ejecuta cuando el progreso en GameManager cambia
	"""
	print("Progreso actualizado desde GameManager")

# Actualizar GameManager cuando avance el diálogo
func on_dialogo_avanza(nuevo_indice: int) -> void:
	GameManager.actualizar_dialogo(nuevo_indice)
```

### 3.2 Modificar menu_conversacion.gd

Cambiar las funciones para usar GameManager:

**BUSCA ESTO:**

```gdscript
func _on_guardar_pressed() -> void:
	print("📍 Guardar progreso solicitado")
	accion_pendiente = "guardar"
	get_tree().change_scene_to_file("res://menu/slots.tscn")
```

**REEMPLAZA POR:**

```gdscript
func _on_guardar_pressed() -> void:
	print("📍 Guardar progreso solicitado")
	GameManager.establecer_accion_pendiente("guardar")
	get_tree().change_scene_to_file("res://menu/slots.tscn")
```

**BUSCA ESTO:**

```gdscript
func _on_cargar_pressed() -> void:
	print("📍 Cargar progreso solicitado")
	accion_pendiente = "cargar"
	get_tree().change_scene_to_file("res://menu/slots.tscn")
```

**REEMPLAZA POR:**

```gdscript
func _on_cargar_pressed() -> void:
	print("📍 Cargar progreso solicitado")
	GameManager.establecer_accion_pendiente("cargar")
	get_tree().change_scene_to_file("res://menu/slots.tscn")
```

---

## PASO 4: Actualizar slots.gd

### 4.1 Agregar al PRINCIPIO de slots.gd (después de `extends Control`):

```gdscript
# Referencia a GameManager
var game_manager: Node

func _ready() -> void:
	# Obtener referencia a GameManager
	game_manager = get_node("/root/GameManager")

	# Conectar botones (código original sigue igual)
	...
```

### 4.2 Modificar función `_on_slot_pressed()`:

**BUSCA ESTO:**

```gdscript
func _on_slot_pressed(numero_slot: int) -> void:
	print("Slot %d seleccionado" % numero_slot)
	slot_seleccionado = numero_slot
	var progreso = cargar_progreso_de_slot(numero_slot)
	...
```

**REEMPLAZA POR:**

```gdscript
func _on_slot_pressed(numero_slot: int) -> void:
	print("Slot %d seleccionado" % numero_slot)
	slot_seleccionado = numero_slot

	# Obtener acción pendiente
	var accion = game_manager.obtener_accion_pendiente()

	if accion == "guardar":
		# Guardar en este slot
		game_manager.guardar_en_slot(numero_slot)
		print("✓ Guardado en Slot %d" % numero_slot)
		# Esperar un poco y volver a cap_1
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/cap_1.tscn")

	elif accion == "cargar":
		# Cargar desde este slot
		game_manager.cargar_desde_slot(numero_slot)
		print("✓ Cargado desde Slot %d" % numero_slot)
		# Esperar un poco y volver a cap_1
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/cap_1.tscn")

	else:
		# Sin acción pendiente, solo cargar la información
		var progreso = cargar_progreso_de_slot(numero_slot)
		progreso_actual = progreso
		print("Información del Slot %d cargada" % numero_slot)
```

---

## PASO 5: Verificar que Todo Funciona

### 5.1 Prueba en Godot

```
1. Abre el proyecto
2. Project → Project Settings → Autoload
3. Verifica que GameManager esté listado
4. Abre res://scenes/cap_1.tscn
5. Presiona F5 (Play)
6. En la consola debe aparecer:
   ✓ GameManager inicializado
   ✓ cap_1.gd cargado
   ✓ Menú flotante visible
```

### 5.2 Prueba los Botones

```
✅ Botón "💾 Guardar"
   → Abre slots.tscn
   → Hace clic en un slot
   → Vuelve a cap_1

✅ Botón "📂 Cargar"
   → Abre slots.tscn
   → Hace clic en un slot
   → Vuelve a cap_1

✅ Botón "❌ Menú"
   → Muestra confirmación
   → Regresa a menu.tscn
```

---

## 📊 Resultado Final

### Estado de Scripts

```
cap_1.gd                    ✅ Diálogos (se ejecuta)
menu_conversacion.gd        ✅ Menú flotante (se ejecuta)
game_manager.gd             ✅ AutoLoad global (siempre disponible)
slots.gd                    ✅ Guardado/carga (modificado)
```

### Flujo de Datos

```
cap_1.gd (Diálogos)
    ↓ Actualiza mediante
    ↓
GameManager (Estado Global)
    ↓ Lee desde
    ↓
menu_conversacion.gd (Menú)
    ↓ Establece acción
    ↓
slots.gd (Guardado/carga)
    ↓ Usa
    ↓
GameManager (Guardar/cargar datos)
    ↓ Retorna a
    ↓
cap_1.gd (Restaura estado)
```

---

## 🧩 Funciones Disponibles en GameManager

```gdscript
# Guardar/Cargar
GameManager.guardar_en_slot(numero_slot: int) -> bool
GameManager.cargar_desde_slot(numero_slot: int) -> bool

# Actualizar Estado
GameManager.actualizar_capitulo(nuevo_capitulo: int)
GameManager.actualizar_dialogo(nuevo_indice: int)
GameManager.actualizar_emocion(nueva_emocion: String)
GameManager.actualizar_estado_puzzle(id: String, completado: bool, intentos: int)

# Acciones
GameManager.establecer_accion_pendiente(accion: String)
GameManager.limpiar_accion_pendiente()
GameManager.obtener_accion_pendiente() -> String

# Información
GameManager.obtener_progreso() -> Dictionary
GameManager.obtener_estado_slot(numero_slot: int) -> Dictionary
GameManager.obtener_todos_slots() -> Array
GameManager.existe_progreso_guardado(numero_slot: int) -> bool

# Debug
GameManager.debug_mostrar_progreso()
GameManager.debug_mostrar_todos_slots()
```

---

## 🐛 Si Hay Problemas

### "Error: 'GameManager' is not declared"

→ GameManager no está configurado como AutoLoad
→ Solución: Vuelve a PASO 1

### "Error: Invalid get index 'MenuFlotante' on base 'Control'"

→ cap_1.tscn tiene un problema con los nodos
→ Solución: Verifica que el script en cap_1.tscn sea cap_1.gd (ExtResource("1_hb74n"))

### Los diálogos no aparecen

→ cap_1.gd no se está ejecutando
→ Solución: Verifica que el script de Cap1 sea ExtResource("1_hb74n")

### El menú no aparece

→ menu_conversacion.gd no se está ejecutando
→ Solución: Verifica que haya un nodo con ese script o sea un AutoLoad adicional

---

## ✅ Checklist Final

```
[✅] GameManager.gd creado
[  ] GameManager agregado como AutoLoad
[  ] cap_1.tscn script cambiado a cap_1.gd
[  ] cap_1.gd actualizado para conectar con GameManager
[  ] menu_conversacion.gd actualizado para usar GameManager
[  ] slots.gd actualizado para leer de GameManager
[  ] Probado en Godot sin errores
[  ] Botones funcionan correctamente
[  ] Guardado/carga funciona
```

---

**¡LISTO! 🎉**

Ahora todos los scripts trabajan juntos sin conflictos.
GameManager actúa como el "cerebro" del juego.
