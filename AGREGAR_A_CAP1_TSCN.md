# 🎯 AGREGAR A cap_1.tscn - Código Exacto

## Paso 1: Agregar Referencia del Script al Archivo .tscn

Busca en `cap_1.tscn` esta sección (alrededor de la línea 1):

```
[ext_resource type="Script" uid="uid://di6gpeoyka222" path="res://scripts/cap_1.gd" id="1_hb74n"]
```

**Después de esta línea, agrega:**

```
[ext_resource type="Script" uid="uid://menu_conversacion_gd" path="res://scripts/menu_conversacion.gd" id="2_menu_conv"]
```

---

## Paso 2: Asignar Script al Nodo Raíz

Busca (línea ~134):

```
[node name="Cap1" type="Control" unique_id=526565439]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_hb74n")
```

**Cambia `script = ExtResource("1_hb74n")` a:**

```
script = ExtResource("2_menu_conv")
```

> **NOTA**: Esto reemplazaría el script original. Si quieres mantener ambos, usa AutoLoad (ver guía).

---

## Paso 3: Agregar Nodos Visuales

**Al final de cap_1.tscn, antes del cierre `[/gd_scene]`, agrega:**

```tscn
# ========== PANEL FLOTANTE - MENÚ ==========
[node name="MenuFlotante" type="Panel" parent="." unique_id=1820708935]
layout_mode = 1
anchors_preset = 3
anchor_left = 0.9
anchor_top = 0.05
anchor_right = 0.98
anchor_bottom = 0.25
grow_horizontal = 0
grow_vertical = 0
theme_override_styles/panel = SubResource("StyleBoxPanel_menu")

[node name="VBoxContainer" type="VBoxContainer" parent="MenuFlotante" unique_id=1389216837]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
separation = 10
alignment = 1

[node name="BtnGuardar" type="Button" parent="MenuFlotante/VBoxContainer" unique_id=585440516]
custom_minimum_size = Vector2(150, 40)
layout_mode = 2
text = "💾 Guardar"
theme_override_font_sizes/font_size = 18

[node name="BtnCargar" type="Button" parent="MenuFlotante/VBoxContainer" unique_id=585440517]
custom_minimum_size = Vector2(150, 40)
layout_mode = 2
text = "📂 Cargar"
theme_override_font_sizes/font_size = 18

[node name="BtnMenu" type="Button" parent="MenuFlotante/VBoxContainer" unique_id=585440518]
custom_minimum_size = Vector2(150, 40)
layout_mode = 2
text = "❌ Menú"
theme_override_font_sizes/font_size = 18

# ========== PANEL DE CONFIRMACIÓN - MODAL ==========
[node name="PanelConfirmacion" type="Panel" parent="." unique_id=1820708936]
visible = false
layout_mode = 1
anchors_preset = 7
anchor_left = 0.25
anchor_top = 0.35
anchor_right = 0.75
anchor_bottom = 0.65
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = SubResource("StyleBoxPanel_confirmacion")

[node name="VBoxContainer" type="VBoxContainer" parent="PanelConfirmacion" unique_id=1389216838]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
separation = 20
alignment = 1

[node name="Etiqueta" type="Label" parent="PanelConfirmacion/VBoxContainer" unique_id=903630957]
layout_mode = 2
text = "¿Regresar al menú sin guardar?"
theme_override_font_sizes/font_size = 24
alignment = 1

[node name="HBoxContainer" type="HBoxContainer" parent="PanelConfirmacion/VBoxContainer" unique_id=1389216839]
layout_mode = 2
separation = 20
alignment = 1

[node name="BtnConfirmar" type="Button" parent="PanelConfirmacion/VBoxContainer/HBoxContainer" unique_id=585440519]
custom_minimum_size = Vector2(100, 50)
layout_mode = 2
text = "Sí"
theme_override_font_sizes/font_size = 18

[node name="BtnCancelar" type="Button" parent="PanelConfirmacion/VBoxContainer/HBoxContainer" unique_id=585440520]
custom_minimum_size = Vector2(100, 50)
layout_mode = 2
text = "No"
theme_override_font_sizes/font_size = 18

# ========== ESTILOS (Sub-Resources) ==========
[sub_resource type="StyleBoxFlat" id="StyleBoxPanel_menu"]
bg_color = Color(0.3, 0.3, 0.3, 0.8)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.5, 0.5, 0.5, 1.0)
corner_radius_top_left = 5
corner_radius_top_right = 5
corner_radius_bottom_right = 5
corner_radius_bottom_left = 5

[sub_resource type="StyleBoxFlat" id="StyleBoxPanel_confirmacion"]
bg_color = Color(0.2, 0.2, 0.2, 0.9)
border_width_left = 3
border_width_top = 3
border_width_right = 3
border_width_bottom = 3
border_color = Color(0.8, 0.2, 0.2, 1.0)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
```

---

## Paso 4: Actualizar Referencias de SubResources en el Prólogo

**AL INICIO de cap_1.tscn, después de los `[ext_resource]`, agrega:**

```tscn
[sub_resource type="StyleBoxFlat" id="StyleBoxPanel_menu"]
bg_color = Color(0.3, 0.3, 0.3, 0.8)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.5, 0.5, 0.5, 1.0)
corner_radius_top_left = 5
corner_radius_top_right = 5
corner_radius_bottom_right = 5
corner_radius_bottom_left = 5

[sub_resource type="StyleBoxFlat" id="StyleBoxPanel_confirmacion"]
bg_color = Color(0.2, 0.2, 0.2, 0.9)
border_width_left = 3
border_width_top = 3
border_width_right = 3
border_width_bottom = 3
border_color = Color(0.8, 0.2, 0.2, 1.0)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
```

---

## ✅ Estructura Final de cap_1.tscn

```
[gd_scene format=3 uid="uid://mq3d7j3upxxc"]

[ext_resource type="Script" uid="uid://di6gpeoyka222" path="res://scripts/cap_1.gd" id="1_hb74n"]
[ext_resource type="Script" uid="uid://menu_conversacion_gd" path="res://scripts/menu_conversacion.gd" id="2_menu_conv"]  ← NUEVA
[ext_resource type="Texture2D" uid="uid://c05u51n40nfu" path="res://assets/backgrounds/scene1.jpg" id="2_fevyc"]
...

[sub_resource type="StyleBoxFlat" id="StyleBoxPanel_menu"]  ← NUEVO
...

[sub_resource type="StyleBoxFlat" id="StyleBoxPanel_confirmacion"]  ← NUEVO
...

[node name="Cap1" type="Control" ...]
script = ExtResource("2_menu_conv")  ← CAMBIAR AQUÍ O EN AUTOLOAD

    [node name="Fondo" type="TextureRect" ...]
    ...
    [node name="Dialogos" type="Control" ...]
    ...

    [node name="MenuFlotante" type="Panel" ...]  ← NUEVO
    ...

    [node name="PanelConfirmacion" type="Panel" ...]  ← NUEVO
    ...
```

---

## 🚀 ¿Listo para Aplicar Cambios?

Tienes dos opciones:

### Opción 1: Aplicar manualmente

- Abre `res://scenes/cap_1.tscn` en un editor de texto
- Copia y pega el código anterior

### Opción 2: Usar el editor visual

- Abre `res://scenes/cap_1.tscn` en Godot
- Crea manualmente cada nodo según la estructura

**¿Cuál prefieres que haga?**
