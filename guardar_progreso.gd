# Función para guardar el progreso del jugador en un archivo JSON
# Compatible con Godot 4.x

extends Node

# Función que guarda el progreso del usuario
func guardar_progreso(usuario: String) -> bool:
	# Validar que el nombre de usuario no esté vacío
	if usuario.is_empty():
		push_error("El nombre de usuario no puede estar vacío")
		return false
	
	# Crear la ruta del archivo de progreso
	var ruta_archivo = "user://progreso_%s.json" % usuario
	
	# Crear el diccionario con los datos del progreso
	var datos_progreso = {
		"usuario": usuario,
		"capitulo_actual": 1,              # Capítulo en el que está el jugador
		"indice_dialogo": 0,               # Índice del último diálogo visto
		"estado_puzzles": {},              # Diccionario con el estado de cada puzzle
		"timestamp": Time.get_ticks_msec() # Marca de tiempo del guardado
	}
	
	# Ejemplo de estructura de puzzles (personalizar según necesidad)
	# Cada puzzle tiene un ID único y un estado (completado true/false)
	datos_progreso["estado_puzzles"] = {
		"puzzle_1": {"completado": false, "intentos": 0},
		"puzzle_2": {"completado": false, "intentos": 0},
		"puzzle_3": {"completado": false, "intentos": 0}
	}
	
	# Convertir el diccionario a formato JSON
	var json_string = JSON.stringify(datos_progreso, "\t")
	
	# Crear un objeto File para escribir
	var archivo = FileAccess.open(ruta_archivo, FileAccess.WRITE)
	
	# Verificar si el archivo se abrió correctamente
	if archivo == null:
		push_error("No se pudo abrir el archivo: " + ruta_archivo)
		return false
	
	# Escribir el contenido JSON en el archivo
	archivo.store_string(json_string)
	
	# Confirmar que el archivo se guardó correctamente
	if FileAccess.file_exists(ruta_archivo):
		print("✓ Progreso guardado exitosamente en: " + ruta_archivo)
		return true
	else:
		push_error("Error al guardar el archivo de progreso")
		return false


# Función para cargar el progreso del usuario desde el archivo JSON
# Restaura capítulo, diálogo y estado de puzzles. Si no existe el archivo, inicia desde capítulo 1
func cargar_progreso(usuario: String) -> Dictionary:
	# Validar que el nombre de usuario no esté vacío
	if usuario.is_empty():
		push_error("El nombre de usuario no puede estar vacío")
		return _crear_progreso_inicial()
	
	# Crear la ruta del archivo de progreso
	var ruta_archivo = "user://progreso_%s.json" % usuario
	
	# Verificar si el archivo existe
	if not FileAccess.file_exists(ruta_archivo):
		print("⚠ Archivo de progreso no encontrado para '%s'. Iniciando nuevo juego..." % usuario)
		return _crear_progreso_inicial()
	
	# Intenta leer el archivo de progreso
	var archivo = FileAccess.open(ruta_archivo, FileAccess.READ)
	if archivo == null:
		push_error("❌ No se pudo abrir el archivo: " + ruta_archivo)
		# Si hay error al leer, retorna progreso inicial
		return _crear_progreso_inicial()
	
	# Obtener todo el contenido del archivo como string
	var contenido_json = archivo.get_as_text()
	
	# Validar que el contenido no esté vacío
	if contenido_json.is_empty():
		push_error("❌ El archivo de progreso está vacío: " + ruta_archivo)
		return _crear_progreso_inicial()
	
	# Parsear el contenido JSON a un diccionario
	var json = JSON.new()
	var error = json.parse(contenido_json)
	
	# Verificar si el parseo fue exitoso
	if error != OK:
		push_error("❌ Error al parsear JSON: " + json.get_error_message())
		return _crear_progreso_inicial()
	
	# Validar que los datos parseados sean un diccionario
	var datos = json.data
	if datos is not Dictionary:
		push_error("❌ Formato JSON inválido: los datos no son un diccionario")
		return _crear_progreso_inicial()
	
	# Validar que contiene los campos esenciales
	if not _validar_datos_progreso(datos):
		push_error("❌ El archivo de progreso está corrupto o incompleto")
		return _crear_progreso_inicial()
	
	# Progreso cargado exitosamente
	print("✓ Progreso cargado exitosamente para: " + usuario)
	print("  → Capítulo: %d | Diálogo: %d | Puzzles: %d" % [
		datos.capitulo_actual,
		datos.indice_dialogo,
		datos.estado_puzzles.size()
	])
	
	return datos


# Función para crear un progreso inicial (usado cuando no hay archivo guardado)
func _crear_progreso_inicial() -> Dictionary:
	# Retorna un diccionario con los valores por defecto
	return {
		"usuario": "",
		"capitulo_actual": 1,              # Comienza en capítulo 1
		"indice_dialogo": 0,               # Sin diálogos iniciados
		"estado_puzzles": {                # Todos los puzzles sin completar
			"puzzle_1": {"completado": false, "intentos": 0},
			"puzzle_2": {"completado": false, "intentos": 0},
			"puzzle_3": {"completado": false, "intentos": 0}
		},
		"timestamp": Time.get_ticks_msec() # Marca de tiempo actual
	}


# Función auxiliar para validar que el diccionario tenga los campos requeridos
func _validar_datos_progreso(datos: Dictionary) -> bool:
	# Corrección automática de tipos
	if typeof(datos["capitulo_actual"]) != TYPE_INT:
		datos["capitulo_actual"] = int(datos["capitulo_actual"])
	if typeof(datos["indice_dialogo"]) != TYPE_INT:
		datos["indice_dialogo"] = int(datos["indice_dialogo"])

	# Verificar que existan los campos esenciales
	var campos_requeridos = ["usuario", "capitulo_actual", "indice_dialogo", "estado_puzzles"]
	for campo in campos_requeridos:
		if not campo in datos:
			push_error("Campo faltante en el progreso: " + campo)
			return false
	# Validar tipos finales
	if not datos.capitulo_actual is int:
		push_error("capitulo_actual debe ser un entero")
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
