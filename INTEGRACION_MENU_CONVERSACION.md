# 🎮 GUÍA: Integración del Menú de Conversación

## 📍 Estado Actual

✓ Script creado: `res://scripts/menu_conversacion.gd`
✗ Escena no modificada: `res://scenes/cap_1.tscn`

---

## 🛠️ PASO 1: Agregar el Script a cap_1.tscn

### Opción A: Desde el Editor Visual (Recomendado)

1. Abre `res://scenes/cap_1.tscn` en el editor de Godot
2. Selecciona el nodo raíz **"Cap1"** (Control)
3. En el inspector, pestaña **"Attach Script"**
4. Selecciona `res://scripts/menu_conversacion.gd`

### Opción B: Editar el archivo .tscn directamente

Busca la línea en `cap_1.tscn`:

```
[node name="Cap1" type="Control" unique_id=526565439]
layout_mode = 3
anchors_preset = 15
script = ExtResource("1_hb74n")
```

Cambia a:

```
[node name="Cap1" type="Control" unique_id=526565439]
layout_mode = 3
anchors_preset = 15
script = ExtResource("1_hb74n")  # Mantener el original cap_1.gd
```

**NOTA**: Si quieres usar SOLO `menu_conversacion.gd`, cambia la referencia del script.

---

## 🎨 PASO 2: Crear la Estructura de Nodos Visuales

Debes agregar estos nodos **dentro de Cap1** (en el inspector de escena):

```
Cap1 (Control)
├── [Nodos existentes del diálogo]
│   ├── Fondo
│   ├── Personajes
│   ├── DialogosBase
│   └── Dialogos
│
└── MenuFlotante (Panel) ← NUEVO
    └── VBoxContainer (VBoxContainer)
        ├── BtnGuardar (Button) → Text: "💾 Guardar"
        ├── BtnCargar (Button) → Text: "📂 Cargar"
        └── BtnMenu (Button) → Text: "❌ Menú"

└── PanelConfirmacion (Panel) ← NUEVO (oculto al inicio)
    └── VBoxContainer (VBoxContainer)
        ├── Etiqueta (Label) → Text: "¿Regresar al menú sin guardar?"
        └── HBoxContainer (HBoxContainer)
            ├── BtnConfirmar (Button) → Text: "Sí"
            └── BtnCancelar (Button) → Text: "No"
```

---

## 📐 PASO 3: Configurar Posiciones y Estilos

### MenuFlotante (Panel flotante superior derecho)

- **Posición**: Ancla en TOP-RIGHT
  - `anchor_left = 0.9` (90% del ancho)
  - `anchor_top = 0.05` (5% del alto)
  - `anchor_right = 0.98` (98% del ancho)
  - `anchor_bottom = 0.25` (25% del alto)

- **Tamaño mínimo**: 200x150 píxeles
- **Color de fondo**: RGB(0.3, 0.3, 0.3, 0.8) (semi-transparente)

### VBoxContainer (dentro de MenuFlotante)

- `separation = 10` (espaciado entre botones)
- `alignment = CENTER`

### Botones

- Tamaño mínimo: 150x40 cada uno
- Fuente: 18pt
- Colores:
  - **BtnGuardar**: Verde (#00FF00)
  - **BtnCargar**: Azul (#0099FF)
  - **BtnMenu**: Rojo (#FF3333)

### PanelConfirmacion (Modal en centro)

- **Posición**: Centrada
  - `anchor_left = 0.25`
  - `anchor_top = 0.35`
  - `anchor_right = 0.75`
  - `anchor_bottom = 0.65`
- **Color**: RGB(0.2, 0.2, 0.2, 0.9)
- **Visible = false** (comienza oculto)

---

## ⚙️ PASO 4: Conectar Referencias en el Script

Asegúrate de que estos nodos coincidan exactamente con las rutas del script:

```gdscript
@onready var btn_guardar: Button = $MenuFlotante/VBoxContainer/BtnGuardar
@onready var btn_cargar: Button = $MenuFlotante/VBoxContainer/BtnCargar
@onready var btn_menu: Button = $MenuFlotante/VBoxContainer/BtnMenu

@onready var panel_confirmacion: Panel = $PanelConfirmacion
@onready var lbl_confirmacion: Label = $PanelConfirmacion/VBoxContainer/Etiqueta
@onready var btn_confirmar: Button = $PanelConfirmacion/VBoxContainer/HBoxContainer/BtnConfirmar
@onready var btn_cancelar: Button = $PanelConfirmacion/VBoxContainer/HBoxContainer/BtnCancelar
```

**Si los nombres no coinciden, el script lanzará errores en tiempo de ejecución.**

---

## 🔗 PASO 5: Integrar con el Script Original cap_1.gd

Modificar `res://scripts/cap_1.gd` para que el script del menú NO interfiera con el sistema de diálogos:

**Opción A** (Recomendada): Agregar el menú como AutoLoad

1. En `Project → Project Settings → Autoload`
2. Agregar `res://scripts/menu_conversacion.gd` como "MenuConversacion"
3. Estará disponible en toda la aplicación

**Opción B**: Mantener ambos scripts

- El script `menu_conversacion.gd` gestiona solo el menú flotante
- El script `cap_1.gd` gestiona los diálogos
- Ambos trabajan en paralelo sin conflictos

---

## ✅ PASO 6: Verificación

Después de configurar, haz clic en **"Reproducir"** y verifica:

- [ ] Aparecen 3 botones en la esquina superior derecha
- [ ] Al hacer click en "Guardar" → va a `res://menu/slots.tscn`
- [ ] Al hacer click en "Cargar" → va a `res://menu/slots.tscn`
- [ ] Al hacer click en "Menú" → muestra panel de confirmación
  - [ ] "Sí" → regresa a `res://menu/menu.tscn`
  - [ ] "No" → cierra el panel

---

## 📝 PRÓXIMOS PASOS (FASE 2)

Una vez funcionando el menú flotante:

1. Integrar `slots.gd` para leer `accion_pendiente`
2. Guardar/cargar datos de progreso automáticamente
3. Validar persistencia entre escenas

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### "Error: Expected identifier '\_on_guardar_pressed'"

→ Verifica que el nodo Cap1 tenga asignado el script `menu_conversacion.gd`

### "Error: Invalid get index 'MenuFlotante' on base 'Control'"

→ Verifica que los nodos tengan exactamente estos nombres:

- `MenuFlotante`
- `PanelConfirmacion`
- `VBoxContainer` (dentro de ambos)

### Los botones no funcionan

→ Abre la consola (View → Toggle Console) y verifica los errores

---

**Estado**: 🟡 SCRIPT LISTO - PENDIENTE CREAR NODOS VISUALES EN cap_1.tscn
