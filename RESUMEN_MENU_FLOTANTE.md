# 📋 RESUMEN: Menú Flotante para Escena de Conversación

## 📁 Archivos Creados

### 1. **Script Principal**

📄 `res://scripts/menu_conversacion.gd`

- ✅ Gestiona 3 botones: Guardar, Cargar, Menú
- ✅ Panel de confirmación al regresar
- ✅ Cambios de escena con rutas relativas
- ✅ Señales para comunicación con otros sistemas
- ✅ Totalmente en español

### 2. **Documentación**

📄 `INTEGRACION_MENU_CONVERSACION.md`

- Guía paso a paso para integrar el script
- Configuración de posiciones y estilos
- Solución de problemas

📄 `AGREGAR_A_CAP1_TSCN.md`

- Código exacto para agregar a cap_1.tscn
- Estructura de nodos
- Sub-resources (estilos)

---

## 🎮 Funcionalidad

```
MENÚ FLOTANTE (superior derecha)
├─ 💾 Guardar
│  └─ → Abre res://menu/slots.tscn en modo "guardar"
├─ 📂 Cargar
│  └─ → Abre res://menu/slots.tscn en modo "cargar"
└─ ❌ Menú
   └─ → Muestra confirmación → Regresa a res://menu/menu.tscn

PANEL DE CONFIRMACIÓN (modal centrado)
├─ Mensaje: "¿Regresar al menú sin guardar?"
├─ Botón: Sí → Confirma acción
└─ Botón: No → Cancela
```

---

## ⚙️ Cómo Funciona el Script

### 1. **Inicialización (\_ready)**

```gdscript
func _ready() -> void:
    # Conecta botones a funciones
    btn_guardar.pressed.connect(_on_guardar_pressed)
    btn_cargar.pressed.connect(_on_cargar_pressed)
    btn_menu.pressed.connect(_on_menu_pressed)

    # Oculta panel de confirmación
    panel_confirmacion.visible = false
```

### 2. **Guardar Progreso**

```gdscript
func _on_guardar_pressed() -> void:
    accion_pendiente = "guardar"
    get_tree().change_scene_to_file("res://menu/slots.tscn")
```

→ Almacena que el usuario quiere guardar  
→ Cambia a la escena de slots  
→ El script `slots.gd` leerá `accion_pendiente` y guardará

### 3. **Cargar Progreso**

```gdscript
func _on_cargar_pressed() -> void:
    accion_pendiente = "cargar"
    get_tree().change_scene_to_file("res://menu/slots.tscn")
```

→ Similar a guardar, pero para cargar

### 4. **Regresar al Menú**

```gdscript
func _on_menu_pressed() -> void:
    _mostrar_confirmacion("¿Regresar al menú sin guardar?")
    accion_pendiente = "menu"
```

→ Muestra panel de confirmación  
→ Si "Sí" → va a `res://menu/menu.tscn`  
→ Si "No" → cancela

---

## 📐 Estructura de Nodos (en cap_1.tscn)

```
Cap1 (Control)
├── [EXISTENTES] Fondo, Personajes, Dialogos, etc...
├── MenuFlotante (Panel)
│   └── VBoxContainer
│       ├── BtnGuardar (Button)
│       ├── BtnCargar (Button)
│       └── BtnMenu (Button)
└── PanelConfirmacion (Panel)
    └── VBoxContainer
        ├── Etiqueta (Label)
        └── HBoxContainer
            ├── BtnConfirmar (Button)
            └── BtnCancelar (Button)
```

---

## 🔗 Rutas de Escenas

```
res://menu/menu.tscn          ← Menú principal
res://scenes/cap_1.tscn       ← Escena de conversación (AQUÍ ESTÁ EL MENÚ NUEVO)
res://menu/slots.tscn         ← Sistema de guardado/carga
```

---

## 🚀 PRÓXIMA FASE: Integración con Slots

Después de agregar el menú flotante, necesitaremos:

1. **Modificar slots.gd** para leer `accion_pendiente`
2. **Guardar datos** cuando se presione "Guardar"
3. **Cargar datos** cuando se presione "Cargar"
4. **Volver a cap_1** después de guardar/cargar

---

## ❓ Preguntas Frecuentes

**P: ¿Esto elimina el script original de cap_1.gd?**
R: No necesariamente. Puedes usar AutoLoad para tener ambos.

**P: ¿Cómo vinculo slots.gd con este menú?**
R: Ya está preparado. El script guarda `accion_pendiente` que slots.gd puede leer.

**P: ¿Funcionan los diálogos originales?**
R: Sí, el menú solo agrega nuevos nodos. No interfiere con los diálogos.

---

## ✅ PRÓXIMO PASO

¿Quieres que:

1. **Modifique cap_1.tscn directamente** (aplicar el código)
2. **Crees una guía visual** con screenshots
3. **Integres con slots.gd** (FASE 2)

¿Cuál es tu preferencia?
