# slots.gd
# ============================================================================
# SISTEMA MEJORADO DE GUARDADO CON MÚLTIPLES SLOTS
# Incluye miniaturas de pantalla, fecha/hora y visualización en la interfaz
# ============================================================================
# Este script gestiona 3 slots de guardado con:
# - Captura de pantalla como miniatura (200x150)
# - Almacenamiento de JSON con datos de progreso
# - Visualización en tiempo real en la UI
# - Soporte para capítulo, diálogos y estado de puzzles
# ============================================================================

extends Control

# ============================================================================
# CONSTANTES - Configuración de slots
# ============================================================================
const NUMERO_SLOTS = 3                          # Total de ranuras disponibles
const RUTA_BASE = "user://"                     # Ruta base para guardar archivos
const NOMBRE_ARCHIVO_JSON = "slot%d.json"       # Formato: slot1.json, slot2.json, etc.
const NOMBRE_ARCHIVO_PNG = "slot%d.png"         # Formato: slot1.png, slot2.png, etc.
const TAMAÑO_MINIATURA = Vector2(200, 150)      # Tamaño de la miniatura (ancho x alto)


# ============================================================================
# REFERENCIAS A NODOS DE LOS CONTENEDORES DE SLOTS
# ============================================================================
# Contenedor para el Slot 1 (con TextureRect, Label y Button)
# SLOT 1
@onready var slot1_container: Control = $VBoxContainer/slot1_container
@onready var slot1_texture: TextureRect = slot1_container.get_node("slot1_texture")
@onready var slot1_label: Label = slot1_container.get_node("slot1_vbox/Label")
@onready var slot1_button: Button = slot1_container.get_node("slot1_vbox/Button")

# SLOT 2
@onready var slot2_container: Control = $VBoxContainer/slot2_container
@onready var slot2_texture: TextureRect = slot2_container.get_node("slot2_texture")
@onready var slot2_label: Label = slot2_container.get_node("slot2_vbox/Label")
@onready var slot2_button: Button = slot2_container.get_node("slot2_vbox/Button")

# SLOT 3
@onready var slot3_container: Control = $VBoxContainer/slot3_container
@onready var slot3_texture: TextureRect = slot3_container.get_node("slot3_texture")
@onready var slot3_label: Label = slot3_container.get_node("slot3_vbox/Label")
@onready var slot3_button: Button = slot3_container.get_node("slot3_vbox/Button")

@onready var volver_menu: Button = get_node("menu_flotante/btn_menu")

# ============================================================================
# FUNCIÓN: Se ejecuta cuando se carga la escena en Godot
# Conecta los botones y actualiza la visualización de todos los slots
# ============================================================================
func _ready() -> void:
	# Conectamos los botones a sus respectivas funciones de manejo
	slot1_button.pressed.connect(func(): _on_slot_pressed(1))
	slot2_button.pressed.connect(func(): _on_slot_pressed(2))
	slot3_button.pressed.connect(func(): _on_slot_pressed(3))
	volver_menu.pressed.connect(func(): on_menu_pressed())
	
	# Actualizamos la información visual de todos los slots al iniciar
	actualizar_informacion_todos_slots()
	
	print("✓ Menú de slots mejorado cargado")
	print("  → Integrado con GameManager (AutoLoad)")


# ============================================================================
func on_menu_pressed() -> void:
	GameManager.regresar_al_menu()


# ============================================================================
# FUNCIÓN: Actualiza la información visual de todos los slots
# Lee los datos guardados y actualiza miniaturas, fechas y etiquetas
# ============================================================================
func actualizar_informacion_todos_slots() -> void:
	# Actualizar cada slot (1, 2, 3)
	for numero_slot in range(1, NUMERO_SLOTS + 1):
		_actualizar_slot_visual(numero_slot)


# ============================================================================
# FUNCIÓN AUXILIAR: Actualiza la visualización de un slot específico
# Carga la miniatura PNG y muestra la información de fecha/hora y progreso
# ============================================================================
func _actualizar_slot_visual(numero_slot: int) -> void:
	# Obtener referencias a los nodos del slot
	var texture_rect: TextureRect
	var label: Label
	
	# Seleccionar los nodos según el número de slot
	match numero_slot:
		1:
			texture_rect = slot1_texture
			label = slot1_label
		2:
			texture_rect = slot2_texture
			label = slot2_label
		3:
			texture_rect = slot3_texture
			label = slot3_label
		_:
			return
	
	# Cargar los datos del slot desde el archivo JSON
	var progreso = GameManager.obtener_estado_slot(numero_slot)
	
	# Si el slot está vacío, mostrar estado vacío
	if progreso.is_empty():
		# Intentar cargar imagen de placeholder por defecto
		texture_rect.texture = load("res://assets/void.jpg") 
		label.text = "[SLOT %d - VACÍO]" % numero_slot
		return
	
	# Obtener ruta de la miniatura gestionada por el usuario
	var ruta_miniatura = GameManager.obtener_ruta_miniatura(numero_slot)
	
	# En Godot 4, para archivos externos en user:// usamos Image y ImageTexture
	if FileAccess.file_exists(ruta_miniatura):
		var img = Image.load_from_file(ruta_miniatura)
		var tex = ImageTexture.create_from_image(img)
		texture_rect.texture = tex
	else:
		texture_rect.texture = load("res://assets/void.jpg")
	
	# Formatear y mostrar información: fecha/hora, capítulo y diálogo
	var fecha_hora = GameManager.obtener_timestamp_formateado(progreso.get("timestamp", 0))
	var capitulo = progreso.get("capitulo_actual", 1)
	var dialogo = progreso.get("indice_dialogo", 0)
	
	# Mostrar información en el Label del slot
	label.text = "Slot %d - Cap. %d | Diálogo %d\n%s" % [
		numero_slot,
		capitulo,
		dialogo,
		fecha_hora
	]


# ============================================================================
# FUNCIÓN: Manejador cuando se presiona un botón de slot
# Carga el progreso del slot seleccionado
# ============================================================================
func _on_slot_pressed(numero_slot: int) -> void:
	print("📍 Slot %d seleccionado" % numero_slot)
	
	# Registrar el slot seleccionado
	GameManager.slot_seleccionado = numero_slot
	
	# ─── OBTENER ACCIÓN PENDIENTE DE GameManager
	var accion = GameManager.obtener_accion_pendiente()
	print("  → Acción pendiente: %s" % accion)
	
	# ─── SI ACCIÓN ES "GUARDAR"
	if accion == "guardar":
		print("💾 Guardando progreso en Slot %d..." % numero_slot)
		
		# Guardar usando GameManager
		var exito = GameManager.guardar_en_slot(numero_slot)
		
		if exito:
			print("✓ Progreso guardado exitosamente")
			# Limpiar acción pendiente
			GameManager.limpiar_accion_pendiente()
			# Esperar un poco para que se vea el cambio
			await get_tree().create_timer(1.0).timeout
			# Volver a cap_1
			print("🔄 Volviendo a la escena de conversación...")
			get_tree().change_scene_to_file("res://scenes/cap_1.tscn")
		else:
			print("❌ Error al guardar progreso")
			return
	
	# ─── SI ACCIÓN ES "CARGAR"
	elif accion == "cargar":
		# Verificar si el slot tiene datos
		if not GameManager.existe_progreso_guardado(numero_slot):
			print("⚠ Slot %d vacío - No hay datos para cargar" % numero_slot)
			return
		
		print("📂 Cargando progreso desde Slot %d..." % numero_slot)
		
		# Cargar usando GameManager
		var exito = GameManager.cargar_desde_slot(numero_slot)
		
		if exito:
			print("✓ Progreso cargado exitosamente")
			# Limpiar acción pendiente
			GameManager.limpiar_accion_pendiente()
			# Esperar un poco para que se vea el cambio
			await get_tree().create_timer(1.0).timeout
			# Volver a cap_1
			print("🔄 Volviendo a la escena de conversación...")
			get_tree().change_scene_to_file("res://scenes/cap_1.tscn")
		else:
			print("❌ Error al cargar progreso")
			return
	
	# ─── SIN ACCIÓN: Solo mostrar información del slot
	else:
		print("ℹ Sin acción pendiente - Mostrando información del slot")
		var progreso = GameManager.obtener_estado_slot(numero_slot)
		
		if progreso.is_empty():
			print("⚠ Slot %d está vacío" % numero_slot)
		else:
			GameManager.progreso_actual = progreso
			print("✓ Información del Slot %d cargada" % numero_slot)
			print("  → Capítulo: %d | Diálogo: %d" % [progreso.get("capitulo_actual", 0), progreso.get("indice_dialogo", 0)])


# ============================================================================
# FUNCIÓN PÚBLICA: Obtener el progreso cargado actualmente
# Retorna los datos del progreso en memoria
# ============================================================================
func obtener_progreso_actual() -> Dictionary:
	return GameManager.progreso_actual


# ============================================================================
# FUNCIÓN PÚBLICA: Actualizar el progreso actual
# Se usa cuando cambia el capítulo, diálogo o estado de puzzles en el juego
# ============================================================================
func actualizar_progreso_actual(datos: Dictionary) -> void:
	GameManager.progreso_actual = datos
	print("Progreso actualizado")


# ============================================================================
# FUNCIÓN PÚBLICA: Obtener el slot actualmente seleccionado
# Retorna el número del slot (1, 2 o 3)
# ============================================================================
func obtener_slot_seleccionado() -> int:
	return GameManager.slot_seleccionado
