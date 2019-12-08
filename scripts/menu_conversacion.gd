# ============================================================================
# SCRIPT: Menu de Conversación
# Gestiona: Guardar, Cargar y Regresar al menú desde la escena de diálogo
# Comunica con GameManager (AutoLoad)
# ============================================================================

extends Control

# ─── Referencias a nodos
@onready var btn_guardar: Button = $VBoxContainer/BtnGuardar
@onready var btn_cargar: Button = $VBoxContainer/BtnCargar
@onready var btn_menu: Button = $VBoxContainer/BtnMenu

# ─── Panel de confirmación
@onready var panel_confirmacion: Panel = $"../PanelConfirmacion"
@onready var lbl_confirmacion: Label = $"../PanelConfirmacion/VBoxContainer/Etiqueta"
@onready var btn_confirmar: Button = $"../PanelConfirmacion/VBoxContainer/HBoxContainer/BtnConfirmar"
@onready var btn_cancelar: Button = $"../PanelConfirmacion/VBoxContainer/HBoxContainer/BtnCancelar"

# ─── Variables privadas
var accion_pendiente: String = ""  # Sincronizado con GameManager

# ============================================================================
# FUNCIÓN: Inicialización
# ============================================================================
func _ready() -> void:
	# Conectar botones flotantes a sus funciones
	btn_guardar.pressed.connect(_on_guardar_pressed)
	btn_cargar.pressed.connect(_on_cargar_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)
	
	# Conectar botones del panel de confirmación
	btn_confirmar.pressed.connect(_on_confirmar_pressed)
	btn_cancelar.pressed.connect(_on_cancelar_pressed)
	
	# Ocultar panel de confirmación al inicio
	panel_confirmacion.visible = false
	
	print("✓ Menú de conversación inicializado")


# ============================================================================
# MANEJADORES DE BOTONES FLOTANTES
# ============================================================================

func _on_guardar_pressed() -> void:
	print("Guardar progreso solicitado")
	
	# 1. Capturamos la escena del juego MIENTRAS es visible
	GameManager.capturar_miniatura_en_buffer()
	
	# 2. Preparamos la navegación
	GameManager.establecer_accion_pendiente("guardar")
	
	# Cambiar a la escena de slots
	get_tree().change_scene_to_file("res://menu/slots.tscn")


func _on_cargar_pressed() -> void:
	print("Cargar progreso solicitado")
	
	# Establecer acción en GameManager (AutoLoad)
	GameManager.establecer_accion_pendiente("cargar")
	
	# Cambiar a la escena de slots
	get_tree().change_scene_to_file("res://menu/slots.tscn")


func _on_menu_pressed() -> void:
	print("Regresar al menú solicitado")

	# Establecer acción en GameManager (AutoLoad)
	GameManager.establecer_accion_pendiente("menu")

	# Mostrar panel de confirmación
	_mostrar_confirmacion("¿Regresar al menú sin guardar?")


# ============================================================================
# PANEL DE CONFIRMACIÓN
# ============================================================================

func _mostrar_confirmacion(mensaje: String) -> void:
	"""
	Muestra el panel de confirmación con un mensaje
	"""
	lbl_confirmacion.text = mensaje
	panel_confirmacion.visible = true


func _on_confirmar_pressed() -> void:
	"""
	Ejecuta la acción confirmada
	"""
	match GameManager.obtener_accion_pendiente():
		"menu":
			_regresar_al_menu()
		"guardar":
			print("✓ Guardando...")
		"cargar":
			print("✓ Cargando...")
	
	# Ocultar panel
	panel_confirmacion.visible = false
	GameManager.limpiar_accion_pendiente()


func _on_cancelar_pressed() -> void:
	"""
	Cancela la acción
	"""
	print("Acción cancelada")
	panel_confirmacion.visible = false
	GameManager.limpiar_accion_pendiente()


# ============================================================================
# CAMBIOS DE ESCENA
# ============================================================================

func _regresar_al_menu() -> void:
	"""
	Regresa a la escena del menú principal sin guardar
	"""
	print("Regresando al menú principal...")
	get_tree().change_scene_to_file("res://menu/menu.tscn")


func ir_a_slots_guardar() -> void:
	"""
	Cambia a la escena de slots con intención de guardar
	"""
	accion_pendiente = "guardar"
	get_tree().change_scene_to_file("res://menu/slots.tscn")


func ir_a_slots_cargar() -> void:
	"""
	Cambia a la escena de slots con intención de cargar
	"""
	accion_pendiente = "cargar"
	get_tree().change_scene_to_file("res://menu/slots.tscn")


# ============================================================================
# GETTERS - Información pública
# ============================================================================

func obtener_accion_pendiente() -> String:
	"""
	Retorna la acción que se está esperando realizar
	Obtiene del GameManager (AutoLoad)
	"""
	return GameManager.obtener_accion_pendiente()


func limpiar_accion() -> void:
	"""
	Limpia la acción pendiente (usado después de guardar/cargar)
	"""
	accion_pendiente = ""
