# GameManager.gd
# GESTOR GLOBAL DEL JUEGO
# Centraliza: Estado del juego, guardado/carga, comunicación entre escenas
# ============================================================================

extends Node

# ─── Señales
signal accion_cambio_solicitada(accion: String)
signal progreso_actualizado
signal slot_guardado(numero_slot: int)
signal slot_cargado(numero_slot: int)

# ─── Constantes
const NUMERO_SLOTS = 3
const RUTA_BASE = "user://"
const NOMBRE_ARCHIVO_JSON = "slot%d.json"

# ─── Estado Global del Juego
var capitulo_actual: int = 1
var indice_dialogo: int = 0
var personaje_emocion: String = "Normal"
var estado_puzzles: Dictionary = {}
var timestamp_ultima_accion: int = 0

# ─── Estado de Navegación
var accion_pendiente: String = ""  # "guardar", "cargar" o ""
var slot_seleccionado: int = 0
var progreso_actual: Dictionary = {}
var _miniatura_buffer: Image = null # Almacena la captura antes de cambiar de escena

# ─── Variables de Control
var usuario_actual: String = ""
var escena_anterior: String = ""
var es_primera_carga: bool = true

# ============================================================================
# INICIALIZACIÓN
# ============================================================================

func _ready() -> void:
	print("✓ GameManager inicializado")
	print("  → Disponible globalmente como: GameManager")
	print("  → Capitulo: %d | Dialogo: %d" % [capitulo_actual, indice_dialogo])


# ============================================================================
# NOTIFICACIONES DEL SISTEMA (MANEJO DE CIERRE)
# ============================================================================

func _notification(what: int) -> void:
	# NOTIFICATION_WM_CLOSE_REQUEST se dispara al cerrar la ventana (X) o salir del juego
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_guardar_y_cerrar_sesion()


# ============================================================================
# FUNCIÓN: Guarda el progreso automáticamente al cerrar la aplicación
# ============================================================================

func _guardar_y_cerrar_sesion() -> void:
	"""
	Realiza un guardado de seguridad automático si hay una sesión activa.
	"""
	if usuario_actual.is_empty():
		return
	
	print("⏹ [AutoGuardado] Cierre detectado. Guardando progreso de '%s'..." % usuario_actual)
	
	# Ejecutamos la función de guardado existente
	# Al ser una operación de archivo síncrona, se completará antes de que el proceso muera
	if guardar_progreso(usuario_actual):
		print("✓ AutoGuardado completado exitosamente antes de salir.")
	else:
		push_error("❌ Falló el AutoGuardado de emergencia para: " + usuario_actual)
	
	# Nota: No es estrictamente necesario limpiar las variables en memoria 
	# (como progreso_actual = {}) aquí, ya que el proceso de la aplicación 
	# terminará inmediatamente después de esta función.



# ============================================================================
# FUNCIONES DE GUARDADO
# ============================================================================

func establecer_usuario(usuario: String):
	usuario_actual = usuario

func guardar_en_slot(numero_slot: int) -> bool:
	"""
	Guarda el progreso actual en un slot específico
	"""
	if numero_slot < 1 or numero_slot > NUMERO_SLOTS:
		push_error("Número de slot inválido: %d" % numero_slot)
		return false
	
	# Crear diccionario con los datos del progreso
	var datos_progreso = {
		"numero_slot": numero_slot,
		"capitulo_actual": capitulo_actual,
		"indice_dialogo": indice_dialogo,
		"expresion": personaje_emocion,
		"estado_puzzles": estado_puzzles,
		"timestamp": Time.get_unix_time_from_system(),
		# Actualizacion
		"usuario": usuario_actual
	}
	
	# ─── GUARDAR MINIATURA DESDE EL BUFFER
	# Si existe una imagen capturada previamente, la guardamos en el slot
	if _miniatura_buffer != null:
		var ruta_png = obtener_ruta_miniatura(numero_slot)
		var err = _miniatura_buffer.save_png(ruta_png)
		if err == OK:
			print("💾 Miniatura del buffer guardada en: " + ruta_png)
		# Nota: No limpiamos el buffer aquí por si el usuario guarda en varios slots
	
	# Convertir a JSON
	var json_string = JSON.stringify(datos_progreso, "\t")
	
	# Guardar en archivo (Actualizado)
	var ruta_json = obtener_ruta_slot(numero_slot)
	crear_directorio_usuario()
	var archivo = FileAccess.open(ruta_json, FileAccess.WRITE)
	
	if archivo == null:
		push_error("No se pudo abrir archivo: " + ruta_json)
		return false
	
	archivo.store_string(json_string)
	
	if not FileAccess.file_exists(ruta_json):
		push_error("Error al guardar archivo de slot %d" % numero_slot)
		return false
	
	# Actualizar progreso actual
	progreso_actual = datos_progreso
	slot_seleccionado = numero_slot
	timestamp_ultima_accion = Time.get_ticks_msec()
	
	print("✓ Progreso guardado en Slot %d" % numero_slot)
	print("  → Capítulo: %d | Diálogo: %d" % [capitulo_actual, indice_dialogo])
	
	# Emitir señal
	slot_guardado.emit(numero_slot)
	progreso_actualizado.emit()
	
	return true


func cargar_desde_slot(numero_slot: int) -> bool:
	"""
	Carga el progreso desde un slot específico
	"""
	if numero_slot < 1 or numero_slot > NUMERO_SLOTS:
		push_error("Número de slot inválido: %d" % numero_slot)
		return false
	
	# Crear ruta del archivo (Actualizado)
	var ruta_json = obtener_ruta_slot(numero_slot)
	
	# Verificar que existe
	if not FileAccess.file_exists(ruta_json):
		print("⚠ Slot %d vacío" % numero_slot)
		return false
	
	# Leer archivo
	var archivo = FileAccess.open(ruta_json, FileAccess.READ)
	if archivo == null:
		push_error("No se pudo leer archivo: " + ruta_json)
		return false
	
	# Parsear JSON
	var contenido_json = archivo.get_as_text()
	var json = JSON.new()
	var error = json.parse(contenido_json)
	
	if error != OK:
		push_error("Error al parsear JSON: " + json.get_error_message())
		return false
	
	var datos = json.data
	if datos is not Dictionary:
		push_error("Formato JSON inválido")
		return false
	
	# Aplicar datos cargados
	capitulo_actual = datos.get("capitulo_actual", 1)
	indice_dialogo = datos.get("indice_dialogo", 0)
	personaje_emocion = datos.get("expresion", "Normal")
	estado_puzzles = datos.get("estado_puzzles", {})
	progreso_actual = datos
	slot_seleccionado = numero_slot
	timestamp_ultima_accion = Time.get_ticks_msec()
	
	print("✓ Progreso cargado desde Slot %d" % numero_slot)
	print("  → Capítulo: %d | Diálogo: %d" % [capitulo_actual, indice_dialogo])
	
	# Emitir señal
	slot_cargado.emit(numero_slot)
	progreso_actualizado.emit()
	
	return true


# ============================================================================
# FUNCIÓN AUXILIAR: Valida la integridad de los datos del progreso
# Verifica que existan los campos requeridos y tengan tipos correctos
# ============================================================================
func _validar_datos_progreso(datos: Dictionary) -> bool:

	# Corrección automática de tipos
	if typeof(datos["capitulo_actual"]) != TYPE_INT:
		datos["capitulo_actual"] = int(datos["capitulo_actual"])
	if typeof(datos["indice_dialogo"]) != TYPE_INT:
		datos["indice_dialogo"] = int(datos["indice_dialogo"])

	# Verificar que existan los campos esenciales
	var campos_requeridos = ["capitulo_actual", "indice_dialogo", "estado_puzzles"]
	
	for campo in campos_requeridos:
		if not campo in datos:
			push_error("Campo faltante en el progreso: " + campo)
			return false
	
	# Validar que los tipos de datos sean correctos
	if not datos.capitulo_actual is int:
		push_error("capitulo_actual debe ser un entero")
		return false
	
	if not datos.indice_dialogo is int:
		push_error("indice_dialogo debe ser un entero")
		return false
	
	if not datos.estado_puzzles is Dictionary:
		push_error("estado_puzzles debe ser un diccionario")
		return false
	
	return true


# ============================================================================
# FUNCIONES DE ESTADO
# ============================================================================

func actualizar_capitulo(nuevo_capitulo: int) -> void:
	"""
	Actualiza el capítulo actual
	"""
	capitulo_actual = nuevo_capitulo
	timestamp_ultima_accion = Time.get_ticks_msec()
	progreso_actualizado.emit()
	print("📖 Capítulo actualizado a: %d" % nuevo_capitulo)


func actualizar_dialogo(nuevo_indice: int) -> void:
	"""
	Actualiza el índice del diálogo actual
	"""
	indice_dialogo = nuevo_indice
	timestamp_ultima_accion = Time.get_ticks_msec()
	progreso_actualizado.emit()
	print("💬 Diálogo actualizado a: %d" % nuevo_indice)


func actualizar_emocion(nueva_emocion: String) -> void:
	"""
	Actualiza la emoción del personaje
	"""
	personaje_emocion = nueva_emocion 
	timestamp_ultima_accion = Time.get_ticks_msec()
	progreso_actualizado.emit()


func actualizar_estado_puzzle(id_puzzle: String, completado: bool, intentos: int = 0) -> void:
	"""
	Actualiza el estado de un puzzle
	"""
	if id_puzzle not in estado_puzzles:
		estado_puzzles[id_puzzle] = {}
	
	estado_puzzles[id_puzzle] = {
		"completado": completado,
		"intentos": intentos,
	}
	timestamp_ultima_accion = Time.get_ticks_msec()
	progreso_actualizado.emit()


# ============================================================================
# FUNCIONES DE ACCIONES
# ============================================================================

func establecer_accion_pendiente(accion: String) -> void:
	"""
	Establece la acción a realizar (guardar, cargar, etc)
	"""
	accion_pendiente = accion
	print("Acción pendiente: %s" % accion)
	accion_cambio_solicitada.emit(accion)


func limpiar_accion_pendiente() -> void:
	"""
	Limpia la acción pendiente
	"""
	accion_pendiente = ""
	_miniatura_buffer = null # Liberamos la memoria de la captura


func obtener_accion_pendiente() -> String:
	"""
	Obtiene la acción pendiente actual
	"""
	return accion_pendiente


# ============================================================================
# GETTERS - Información
# ============================================================================

# FUNCIÓN: Obtiene la ruta de la miniatura PNG para un usuario y slot
func obtener_ruta_miniatura(numero_slot: int) -> String:
	return "user://usuarios/%s/slot%d.png" % [
		usuario_actual,
		numero_slot
	]


# Actualizacion
func obtener_ruta_slot(numero_slot: int) -> String:
	return "user://usuarios/%s/slot%d.json" % [
		usuario_actual,
		numero_slot
	]

func obtener_progreso() -> Dictionary:
	"""
	Retorna todos los datos de progreso actual
	"""
	return {
		"capitulo_actual": capitulo_actual,
		"indice_dialogo": indice_dialogo,
		"expresion": personaje_emocion,
		"estado_puzzles": estado_puzzles,
		"slot_seleccionado": slot_seleccionado,
		"timestamp": timestamp_ultima_accion
	}


func obtener_estado_slot(numero_slot: int) -> Dictionary:
	"""
	Obtiene la información de un slot sin cargarlo
	"""
	if numero_slot < 1 or numero_slot > NUMERO_SLOTS:
		return {}
	
	var ruta_json = obtener_ruta_slot(numero_slot)
	
	if not FileAccess.file_exists(ruta_json):
		return {}
	
	var archivo = FileAccess.open(ruta_json, FileAccess.READ)
	if archivo == null:
		return {}
	
	var json = JSON.new()
	if json.parse(archivo.get_as_text()) != OK:
		return {}
	
	return json.data


# FUNCIÓN: Obtiene información de todos los slots para mostrar en interfaz
# Retorna un array de diccionarios con datos de cada slot
func obtener_todos_slots() -> Array:
	"""
	Retorna información de todos los slots
	"""
	var slots = []
	for i in range(1, NUMERO_SLOTS + 1):
		slots.append(obtener_estado_slot(i))
	return slots


func obtener_slot_seleccionado() -> int:
	"""
	Retorna el número del slot seleccionado
	"""
	return slot_seleccionado


func existe_progreso_guardado(numero_slot: int) -> bool:
	"""
	Verifica si existe un progreso guardado en un slot
	"""
	var ruta_json = obtener_ruta_slot(numero_slot)
	return FileAccess.file_exists(ruta_json)


# ============================================================================
# FUNCIONES DE INICIALIZACIÓN
# ============================================================================

func iniciar_nueva_partida() -> void:
	progreso_actual = {}
	capitulo_actual = 1
	indice_dialogo = 0
	personaje_emocion = "Normal"
	estado_puzzles.clear()
	slot_seleccionado = 0
	print("✓ Nueva partida iniciada")

func existe_usuario(nombre_usuario: String) -> bool:
	"""
	Verifica si la carpeta del usuario ya existe en el sistema de archivos.
	"""
	var ruta = "user://usuarios/%s" % nombre_usuario
	return DirAccess.dir_exists_absolute(ruta)


func registrar_usuario(nombre_usuario: String) -> bool:
	"""
	Crea la estructura de carpetas para un nuevo usuario si no existe.
	"""
	if existe_usuario(nombre_usuario):
		push_warning("El usuario ya existe: " + nombre_usuario)
		return false
	
	establecer_usuario(nombre_usuario)
	crear_directorio_usuario()
	
	print("👤 [Registro] Nuevo perfil creado para: %s" % nombre_usuario)
	return true


# FUNCIÓN AUXILIAR: Crear un progreso inicial por defecto
# Retorna un diccionario con valores iniciales para un nuevo juego
func crear_progreso_inicial() -> Dictionary:
	"""
	Crea un progreso inicial para nuevo juego
	"""
	return {
		"usuario": "",
		"capitulo_actual": 1,
		"indice_dialogo": 0,
		"expresion": "Normal",
		"estado_puzzles": {
			"puzzle_1": {"completado": false, "intentos": 0},
			"puzzle_2": {"completado": false, "intentos": 0},
			"puzzle_3": {"completado": false, "intentos": 0}
		},
		"timestamp": Time.get_ticks_msec()
	}


func reiniciar_progreso() -> void:
	"""
	Reinicia el progreso al estado inicial
	"""
	capitulo_actual = 1
	indice_dialogo = 0
	personaje_emocion = "Normal"
	estado_puzzles = {}
	accion_pendiente = ""
	slot_seleccionado = 0
	progreso_actual = {}
	
	print("🔄 Progreso reiniciado")
	progreso_actualizado.emit()


# ============================================================================
# FUNCIONES DEBUG
# ============================================================================

func debug_mostrar_progreso() -> void:
	"""
	Muestra el estado actual en la consola
	"""
	print("\n═══ ESTADO DEL JUEGO ═══")
	print("Capítulo: %d" % capitulo_actual)
	print("Diálogo: %d" % indice_dialogo)
	print("Emoción: %s" % personaje_emocion)
	print("Slot: %d" % slot_seleccionado)
	print("Acción pendiente: %s" % accion_pendiente)
	print("Puzzles: %s" % str(estado_puzzles))
	print("═══════════════════════\n")


func debug_mostrar_todos_slots() -> void:
	"""
	Muestra información de todos los slots
	"""
	print("\n═══ INFORMACIÓN DE SLOTS ═══")
	for i in range(1, NUMERO_SLOTS + 1):
		var slot_info = obtener_estado_slot(i)
		if slot_info.is_empty():
			print("Slot %d: [VACÍO]" % i)
		else:
			print("Slot %d: Cap %d | Diálogo %d | Emoción: %s" % [
				i,
				slot_info.get("capitulo_actual", 0),
				slot_info.get("indice_dialogo", 0),
				slot_info.get("expresion", "?")
			])
	print("════════════════════════════\n")


# ============================================================================
# FUNCIONES DE UTILIDAD
# ============================================================================

# FUNCIÓN: Convierte un timestamp a texto legible (fecha y hora)
# Entrada: timestamp en milisegundos
# Salida: string con formato "DD/MM/YYYY - HH:MM:SS"
func obtener_timestamp_formateado(timestamp: int) -> String:
	"""
	Convierte timestamp a formato legible
	"""
	if timestamp <= 0:
		return "Desconocido"
	var fecha_hora = Time.get_datetime_dict_from_unix_time(timestamp)
	
	return "%04d/%02d/%02d - %02d:%02d:%02d" % [
		fecha_hora.year,
		fecha_hora.month,
		fecha_hora.day,
		fecha_hora.hour,
		fecha_hora.minute,
		fecha_hora.second
	]


func regresar_al_menu() -> void:
	print("Regresando al menú principal...")
	get_tree().change_scene_to_file("res://menu/menu.tscn")


# ============================================================================
# FUNCIÓN: Captura la pantalla actual y la redimensiona a tamaño miniatura
# ============================================================================

func capturar_miniatura_en_buffer() -> void:
	"""
	Captura la pantalla actual y la guarda en memoria.
	Debe llamarse ANTES de cambiar a la escena de slots.
	"""
	await get_tree().process_frame # Esperar a que la UI de pausa se oculte si es necesario
	var imagen : Image = get_viewport().get_texture().get_image()

	if imagen:
		# En Godot 4 las texturas de Viewport están invertidas verticalmente
		imagen.resize(200, 100, Image.INTERPOLATE_LANCZOS)
		_miniatura_buffer = imagen
		print("📷 Pantalla capturada en buffer correctamente.")
	else:
		push_error("❌ Falló la captura de pantalla para el buffer.")



func eliminar_slot(numero_slot: int) -> bool:
	"""
	Elimina un slot completamente
	"""
	if numero_slot < 1 or numero_slot > NUMERO_SLOTS:
		return false
	
	var ruta_json = obtener_ruta_slot(numero_slot)
	
	if FileAccess.file_exists(ruta_json):
		var error = DirAccess.remove_absolute(ruta_json)
		if error == OK:
			print("✓ Slot %d eliminado" % numero_slot)
			return true
	
	return false


# ============================================================================
# FUNCIONES PRIVADAS
# ============================================================================

func crear_directorio_usuario() -> void:
	if usuario_actual.is_empty():
		return
		
	var ruta = "user://usuarios/%s" % usuario_actual

	if not DirAccess.dir_exists_absolute(ruta):
		DirAccess.make_dir_recursive_absolute(ruta)


# ============================================================================
# FUNCIONES PARA CARGAR PROGRESO
# ============================================================================

# FUNCIÓN: Carga el progreso del usuario desde un archivo JSON
# Leer desde: user://progreso_<usuario>.json
# Si no existe, iniciar desde capítulo 1
func cargar_progreso(usuario: String) -> Dictionary:
	# Validar que el nombre de usuario no esté vacío
	if usuario.is_empty():
		push_error("El nombre de usuario no puede estar vacío")
		return crear_progreso_inicial()
	
	# Establecer usuario y asegurar directorio
	establecer_usuario(usuario)
	crear_directorio_usuario()
	
	# Buscar progreso en los slots disponibles
	for slot in range(1, NUMERO_SLOTS + 1):
		var datos = obtener_estado_slot(slot)
		
		if not datos.is_empty():
			# Validar estructura y tipos
			if not _validar_datos_progreso(datos):
				push_error("El archivo del Slot %d está corrupto o incompleto" % slot)
				continue
			
			# Aplicar datos cargados
			capitulo_actual = datos.get("capitulo_actual", 1)
			indice_dialogo = datos.get("indice_dialogo", 0)
			personaje_emocion = datos.get("expresion", "Normal")
			estado_puzzles = datos.get("estado_puzzles", {})
			progreso_actual = datos
			slot_seleccionado = slot
			timestamp_ultima_accion = Time.get_ticks_msec()
			
			print("✓ Progreso cargado para '%s' en Slot %d" % [usuario, slot])
			print("  → Capítulo: %d | Diálogo: %d | Puzzles: %d" % [
				capitulo_actual,
				indice_dialogo,
				estado_puzzles.size()
			])
			
			return datos
	
	# Si no se encontró progreso en ningún slot, iniciar nuevo juego
	print("⚠ No se encontró progreso para '%s'. Iniciando nuevo juego..." % usuario)
	return crear_progreso_inicial()


# ============================================================================
# FUNCIONES PARA PROGRESO GENERAL
# ============================================================================

func guardar_progreso(usuario: String) -> bool:
	# Validar que el nombre de usuario no esté vacío
	if usuario.is_empty():
		push_error("El nombre de usuario no puede estar vacío")
		return false
		
	# Establecer usuario y asegurar directorio
	establecer_usuario(usuario)
	crear_directorio_usuario()
	
	# Determinar slot objetivo
	var slot_objetivo = slot_seleccionado
	if slot_objetivo <= 0:
		slot_objetivo = 1
		
	# Crear diccionario con los datos del progreso actual
	var datos_progreso = {
		"usuario": usuario,
		"numero_slot": slot_objetivo,
		"capitulo_actual": capitulo_actual,
		"indice_dialogo": indice_dialogo,
		"expresion": personaje_emocion,
		"estado_puzzles": estado_puzzles,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Convertir a JSON
	var json_string = JSON.stringify(datos_progreso, "\t")
	
	# Crear ruta y guardar archivo
	var ruta_json = obtener_ruta_slot(slot_objetivo)
	var archivo = FileAccess.open(ruta_json, FileAccess.WRITE)
	
	if archivo == null:
		push_error("No se pudo abrir archivo: " + ruta_json)
		return false
	
	archivo.store_string(json_string)
	
	# Confirmar guardado
	if not FileAccess.file_exists(ruta_json):
		push_error("Error al guardar archivo de slot %d" % slot_objetivo)
		return false
		
	# Actualizar progreso global
	progreso_actual = datos_progreso
	slot_seleccionado = slot_objetivo
	timestamp_ultima_accion = Time.get_ticks_msec()
	
	print("✓ Progreso guardado en Slot %d" % slot_objetivo)
	print("  → Capítulo: %d | Diálogo: %d" % [capitulo_actual, indice_dialogo])
	
	# Emitir señales
	slot_guardado.emit(slot_objetivo)
	progreso_actualizado.emit()
	
	return true
