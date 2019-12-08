# Loggin.gd
extends Control

# ============================================================================
# REFERENCIAS A NODOS DE LA INTERFAZ
# ============================================================================
@onready var user_edit: LineEdit = $VBoxContainer/usuario
@onready var password_edit: LineEdit = $"VBoxContainer/contraseña"
@onready var message_label: Label = $Label
@onready var login_button: Button = $VBoxContainer/Button
@onready var register_button: Button = $VBoxContainer/RegisterButton # Botón nuevo

# ============================================================================
# VARIABLES DE SESIÓN
# ============================================================================
var usuario_actual: String = ""  # Almacena el usuario actualmente logueado

func _ready() -> void:
	# Conectamos la señal del botón al presionarse
	login_button.pressed.connect(_on_login_button_pressed)
	register_button.pressed.connect(_on_register_button_pressed)
	
	# Limpiamos el mensaje inicial
	message_label.text = ""


# ============================================================================
# FUNCIÓN: Maneja el evento del botón de login
# ============================================================================
func _on_login_button_pressed() -> void:
	# Obtenemos los datos del usuario ingresados en los LineEdit
	var usuario_ingresado : String = user_edit.text.strip_edges()
	var password_ingresada : String = password_edit.text
	
	# Validar que los campos no estén vacíos
	if usuario_ingresado.is_empty() or password_ingresada.is_empty():
		_mostrar_error("Por favor, completa todos los campos")
		return
	
	# Validamos si el usuario existe en disco
	if GameManager.existe_usuario(usuario_ingresado):
		_realizar_login(usuario_ingresado)
	else:
		_mostrar_error("El usuario '%s' no existe. Dale a 'Registrar'." % usuario_ingresado)


# ============================================================================
# FUNCIÓN: Maneja el registro de un nuevo usuario
# ============================================================================
func _on_register_button_pressed() -> void:
	var usuario_ingresado : String = user_edit.text.strip_edges()
	
	if usuario_ingresado.is_empty():
		_mostrar_error("Escribe un nombre para registrarte")
		return

	# Intentamos crear el nuevo usuario
	if GameManager.registrar_usuario(usuario_ingresado):
		message_label.modulate = Color.CYAN
		message_label.text = "¡Cuenta '%s' registrada con éxito!" % usuario_ingresado
		
		# Al ser nuevo, reseteamos el progreso en memoria
		GameManager.reiniciar_progreso()
		
		# Esperamos un momento para feedback visual y entramos
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://menu/menu.tscn")
	else:
		_mostrar_error("Ese nombre ya está en uso.")


# =================================================================== =========
# FUNCIÓN: Realiza el login y carga el progreso del jugador
# ============================================================================
func _realizar_login(usuario: String) -> void:
	# Almacenamos el usuario actual para acceso en toda la sesión
	usuario_actual = usuario
	GameManager.establecer_usuario(usuario)
	
	# Cargamos el progreso del usuario desde el archivo JSON
	# Esto busca automáticamente en los slots del usuario
	GameManager.cargar_progreso(usuario)
	
	# Mostrar mensaje de éxito
	message_label.modulate = Color.GREEN
	message_label.text = "¡Bienvenido %s!" % usuario
	
	# Esperamos 1 segundo y luego cambiamos a la escena del menú
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://menu/menu.tscn")


# ============================================================================
# FUNCIÓN: Muestra un mensaje de error en rojo
# ============================================================================

func _mostrar_error(mensaje: String) -> void:
	message_label.modulate = Color.RED
	message_label.text = "❌ " + mensaje
