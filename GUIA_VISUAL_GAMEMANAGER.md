# 🔧 GUÍA VISUAL: Resolver Asunto de Scripts con GameManager

## 📋 Problema Original

```
cap_1.tscn usa menu_conversacion.gd
    ↓
cap_1.gd NO se ejecuta
    ↓
Diálogos NO funcionan
    ↓
Conflicto de scripts
```

## ✅ Solución: GameManager + AutoLoad

```
GameManager (AutoLoad - SIEMPRE DISPONIBLE)
    ↑
    ├← cap_1.gd (Diálogos)
    ├← menu_conversacion.gd (Menú)
    └← slots.gd (Guardado/carga)
```

---

## 🚀 PASO A PASO

### PASO 1: Agregar GameManager como AutoLoad ⭐

#### 1.1 Abre Godot

- Carga tu proyecto

#### 1.2 Ve a AutoLoad

```
Menú superior: Project → Project Settings → Autoload
```

**Verás una ventana como esta:**

```
╔═══════════════════════════════════════╗
║        Project Settings - Autoload    ║
╠═══════════════════════════════════════╣
║ [Node Name] [res://scripts/...]       ║
║ ┌─────────────────────────────────┐   ║
║ │ <lista de autoloads>            │   ║
│ └─────────────────────────────────┘   ║
║ [Carpeta] [Nombre] [Add]              ║
╚═══════════════════════════════════════╝
```

#### 1.3 Agregar GameManager

1. Haz clic en el ícono de **carpeta**
2. Navega a: `res://scripts/`
3. Selecciona: `game_manager.gd`
4. Haz clic en "Abrir"

#### 1.4 Asignar Nombre

```
Node Name: GameManager
```

#### 1.5 Hacer clic en "Add"

```
Resultado: ✅ GameManager: res://scripts/game_manager.gd
```

**Ahora GameManager está disponible globalmente en TODO el proyecto.**

---

### PASO 2: Corregir Script en cap_1.tscn ⭐

#### 2.1 Abre cap_1.tscn

- En el editor de Godot o con editor de texto

#### 2.2 Busca esta línea (alrededor de línea 170):

```
[node name="Cap1" type="Control" ...]
```

#### 2.3 Busca en ese nodo:

```
script = ExtResource("2_menu_conv")
```

#### 2.4 Cámbialo a:

```
script = ExtResource("1_hb74n")
```

**Resultado:**

```
Antes: script = ExtResource("2_menu_conv")  ← menu_conversacion.gd
Después: script = ExtResource("1_hb74n")    ← cap_1.gd ✅
```

#### 2.5 Guarda cap_1.tscn

---

### PASO 3: Actualizar Código en menu_conversacion.gd ⭐

#### 3.1 Abre: `res://scripts/menu_conversacion.gd`

#### 3.2 Busca función:

```gdscript
func _on_guardar_pressed() -> void:
	print("📍 Guardar progreso solicitado")
	accion_pendiente = "guardar"
	get_tree().change_scene_to_file("res://menu/slots.tscn")
```

#### 3.3 Reemplaza por:

```gdscript
func _on_guardar_pressed() -> void:
	print("📍 Guardar progreso solicitado")
	GameManager.establecer_accion_pendiente("guardar")
	get_tree().change_scene_to_file("res://menu/slots.tscn")
```

#### 3.4 Busca función:

```gdscript
func _on_cargar_pressed() -> void:
	print("📍 Cargar progreso solicitado")
	accion_pendiente = "cargar"
	get_tree().change_scene_to_file("res://menu/slots.tscn")
```

#### 3.5 Reemplaza por:

```gdscript
func _on_cargar_pressed() -> void:
	print("📍 Cargar progreso solicitado")
	GameManager.establecer_accion_pendiente("cargar")
	get_tree().change_scene_to_file("res://menu/slots.tscn")
```

#### 3.6 Guarda el archivo

---

### PASO 4: Actualizar Código en slots.gd ⭐

#### 4.1 Abre: `res://menu/slots.gd`

#### 4.2 Busca la función `_ready()`:

```gdscript
func _ready() -> void:
	# Conectar botones
	slot1_button.pressed.connect(func(): _on_slot_pressed(1))
	...
```

#### 4.3 **Antes de conectar botones**, agrega:

```gdscript
func _ready() -> void:
	# Obtener referencia a GameManager
	# (Ya está disponible como AutoLoad)

	# Conectar botones
	slot1_button.pressed.connect(func(): _on_slot_pressed(1))
	slot2_button.pressed.connect(func(): _on_slot_pressed(2))
	slot3_button.pressed.connect(func(): _on_slot_pressed(3))

	actualizar_informacion_todos_slots()
	print("✓ Menú de slots cargado")
```

#### 4.4 Busca función:

```gdscript
func _on_slot_pressed(numero_slot: int) -> void:
	print("Slot %d seleccionado" % numero_slot)
	slot_seleccionado = numero_slot
	var progreso = cargar_progreso_de_slot(numero_slot)
	...
```

#### 4.5 Reemplaza POR:

```gdscript
func _on_slot_pressed(numero_slot: int) -> void:
	print("Slot %d seleccionado" % numero_slot)
	slot_seleccionado = numero_slot

	# Obtener acción pendiente de GameManager
	var accion = GameManager.obtener_accion_pendiente()

	if accion == "guardar":
		# GUARDAR en este slot usando GameManager
		GameManager.guardar_en_slot(numero_slot)
		print("✓ Guardado en Slot %d" % numero_slot)
		# Esperar 1 segundo y volver a cap_1
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/cap_1.tscn")

	elif accion == "cargar":
		# CARGAR desde este slot usando GameManager
		GameManager.cargar_desde_slot(numero_slot)
		print("✓ Cargado desde Slot %d" % numero_slot)
		# Esperar 1 segundo y volver a cap_1
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/cap_1.tscn")

	else:
		# Sin acción pendiente, solo mostrar información del slot
		var progreso = cargar_progreso_de_slot(numero_slot)
		progreso_actual = progreso
		print("Información del Slot %d cargada" % numero_slot)
```

#### 4.6 Guarda el archivo

---

### PASO 5: Verificar todo Funciona ✅

#### 5.1 En Godot

```
Project → Project Settings → Autoload
→ Verifica que aparezca: GameManager ✅
```

#### 5.2 Reproducir Escena

```
1. Abre res://scenes/cap_1.tscn
2. Presiona F5 (Play Scene)
3. En la consola debe aparecer:
   ✓ GameManager inicializado
   ✓ Menú de slots cargado (si lo abres)
```

#### 5.3 Probar Botones

```
✅ "💾 Guardar"
   → Abre slots.tscn
   → Haz clic en un slot
   → Debe guardar automáticamente
   → Vuelve a cap_1

✅ "📂 Cargar"
   → Abre slots.tscn
   → Haz clic en un slot
   → Debe cargar automáticamente
   → Vuelve a cap_1

✅ "❌ Menú"
   → Muestra confirmación
   → "Sí" → Va a menu.tscn
   → "No" → Sigue en cap_1
```

---

## 🎯 Resultado Final

### Antes (Problema)

```
cap_1.tscn
├─ Script: menu_conversacion.gd ← SOLO ESTO SE EJECUTA
├─ Diálogos: ❌ NO FUNCIONAN
└─ Menú: ✅ FUNCIONA
```

### Después (Solución)

```
GameManager (AutoLoad) ← DISPONIBLE EN TODO
├─ Referencia: cap_1.gd, menu_conversacion.gd, slots.gd
└─ Estado: Centralizador

cap_1.tscn
├─ Script: cap_1.gd ✅ SE EJECUTA
├─ Nodo: MenuFlotante con menu_conversacion.gd ✅
├─ Diálogos: ✅ FUNCIONAN
└─ Menú: ✅ FUNCIONA

Comunicación:
cap_1.gd → GameManager → slots.gd
                      ↓
            menu_conversacion.gd
```

---

## 📊 Checklist

```
[  ] PASO 1: GameManager agregado como AutoLoad
[  ] PASO 2: cap_1.tscn script cambiado a cap_1.gd
[  ] PASO 3: menu_conversacion.gd actualizado
[  ] PASO 4: slots.gd actualizado
[  ] PASO 5: Todo funciona sin errores

Si TODOS están marcados: ✅ ÉXITO
```

---

## 🐛 Troubleshooting

| Problema                               | Solución                                                            |
| -------------------------------------- | ------------------------------------------------------------------- |
| "Error: 'GameManager' is not declared" | Vuelve a PASO 1, verifica AutoLoad                                  |
| Los diálogos NO aparecen               | Verifica PASO 2, cap_1.tscn debe tener ExtResource("1_hb74n")       |
| El menú NO aparece                     | Verifica que MenuFlotante exista en cap_1.tscn                      |
| Los botones no guardan                 | Verifica PASO 4, slots.gd debe llamar GameManager.guardar_en_slot() |

---

## 💾 Archivos Modificados

```
✅ Creado: res://scripts/game_manager.gd (NUEVO)
✅ Modificado: res://scenes/cap_1.tscn (script)
✅ Modificado: res://scripts/menu_conversacion.gd
✅ Modificado: res://menu/slots.gd

⚠️ No modificar: res://scripts/cap_1.gd (quedará con su propio script)
```

---

**¡LISTO! 🎉 Todos los scripts funcionan juntos ahora.**
