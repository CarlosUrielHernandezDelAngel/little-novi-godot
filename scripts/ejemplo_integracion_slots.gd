# ============================================================================
# EJEMPLO DE INTEGRACIÓN DEL SISTEMA DE SLOTS CON LA NOVELA VISUAL
# ============================================================================
# Este script muestra cómo usar el sistema de guardado de slots en tu juego
# ============================================================================

extends Node

# ============================================================================
# REFERENCIAS AL SISTEMA DE SLOTS
# ============================================================================
var slots_manager: Control = null  # Referencia al script de slots


# ============================================================================
# VARIABLES DEL JUEGO
# ============================================================================
var capitulo_actual: int = 1
var indice_dialogo_actual: int = 0
var estado_puzzles: Dictionary = {}


func _ready() -> void:
	# Obtener referencia al gestor de slots
	# Nota: Ajusta la ruta según donde cargues la escena de slots
	slots_manager = get_tree().root.get_node("Control")  # o la ruta correcta en tu árbol
	
	# Inicializar estado de puzzles
	_inicializar_puzzles()
	
	print("✓ Ejemplo de integración cargado")


# ============================================================================
# FUNCIÓN: Inicializar el estado de todos los puzzles
# ============================================================================
func _inicializar_puzzles() -> void:
	estado_puzzles = {
		"puzzle_1": {"completado": false, "intentos": 0},
		"puzzle_2": {"completado": false, "intentos": 0},
		"puzzle_3": {"completado": false, "intentos": 0}
	}


# ============================================================================
# FUNCIÓN: Guardar el progreso actual en el slot seleccionado
# Se llama al completar un capítulo o cuando el usuario quiere guardar
# ============================================================================
func guardar_progreso_actual() -> bool:
	if slots_manager == null:
		push_error("❌ No se encontró el gestor de slots")
		return false
	
	# Preparar los datos del progreso actual
	var datos_progreso = {
		"capitulo_actual": capitulo_actual,
		"indice_dialogo": indice_dialogo_actual,
		"estado_puzzles": estado_puzzles
	}
	
	# Actualizar el progreso en el gestor de slots
	slots_manager.actualizar_progreso_actual(datos_progreso)
	
	# Obtener el número del slot seleccionado
	var numero_slot = slots_manager.obtener_slot_seleccionado()
	
	# Guardar en el slot (incluye captura de pantalla automática)
	var guardado_exitoso = slots_manager.guardar_progreso_en_slot(numero_slot)
	
	if guardado_exitoso:
		print("✓ Progreso guardado en Slot %d" % numero_slot)
		print("  → Capítulo: %d | Diálogo: %d" % [capitulo_actual, indice_dialogo_actual])
		return true
	else:
		print("❌ Error al guardar el progreso")
		return false


# ============================================================================
# FUNCIÓN: Cargar un slot específico y restaurar el estado del juego
# ============================================================================
func cargar_slot_especifico(numero_slot: int) -> bool:
	if slots_manager == null:
		push_error("❌ No se encontró el gestor de slots")
		return false
	
	# Cargar los datos del slot
	var progreso = slots_manager.cargar_progreso_de_slot(numero_slot)
	
	# Si el slot está vacío, no hacer nada
	if progreso.is_empty():
		print("⚠ El slot %d está vacío" % numero_slot)
		return false
	
	# Restaurar el estado del juego
	capitulo_actual = progreso.get("capitulo_actual", 1)
	indice_dialogo_actual = progreso.get("indice_dialogo", 0)
	estado_puzzles = progreso.get("estado_puzzles", {})
	
	print("✓ Slot %d cargado exitosamente" % numero_slot)
	print("  → Capítulo: %d | Diálogo: %d" % [capitulo_actual, indice_dialogo_actual])
	
	# Aquí podrías cambiar de escena o actualizar la UI
	# get_tree().change_scene_to_file("res://escenas/novela.tscn")
	
	return true


# ============================================================================
# FUNCIÓN: Avanzar a un nuevo diálogo y guardar automáticamente
# ============================================================================
func avanzar_dialogo() -> void:
	indice_dialogo_actual += 1
	print("📝 Diálogo avanzado a: %d" % indice_dialogo_actual)
	
	# Guardar automáticamente cada N diálogos
	if indice_dialogo_actual % 5 == 0:
		guardar_progreso_actual()


# ============================================================================
# FUNCIÓN: Completar un puzzle y actualizar su estado
# ============================================================================
func completar_puzzle(nombre_puzzle: String) -> void:
	if nombre_puzzle in estado_puzzles:
		estado_puzzles[nombre_puzzle]["completado"] = true
		print("✓ Puzzle '%s' completado" % nombre_puzzle)
		
		# Guardar automáticamente al completar un puzzle
		guardar_progreso_actual()
	else:
		push_error("Puzzle '%s' no existe" % nombre_puzzle)


# ============================================================================
# FUNCIÓN: Registrar un intento fallido en un puzzle
# ============================================================================
func registrar_intento_puzzle(nombre_puzzle: String) -> void:
	if nombre_puzzle in estado_puzzles:
		estado_puzzles[nombre_puzzle]["intentos"] += 1
		print("❌ Intento %d en '%s'" % [
			estado_puzzles[nombre_puzzle]["intentos"],
			nombre_puzzle
		])


# ============================================================================
# FUNCIÓN: Cambiar al siguiente capítulo
# ============================================================================
func siguiente_capitulo() -> void:
	capitulo_actual += 1
	indice_dialogo_actual = 0  # Resetear diálogos para el nuevo capítulo
	print("📖 Capítulo cambiado a: %d" % capitulo_actual)
	
	# Guardar automáticamente al cambiar de capítulo
	guardar_progreso_actual()


# ============================================================================
# FUNCIÓN: Mostrar información de todos los slots disponibles
# ============================================================================
func mostrar_informacion_slots() -> void:
	if slots_manager == null:
		push_error("❌ No se encontró el gestor de slots")
		return
	
	var info_slots = slots_manager.obtener_informacion_todos_slots()
	
	print("\n╔════════════════════════════════════════╗")
	print("║    INFORMACIÓN DE SLOTS DISPONIBLES    ║")
	print("╚════════════════════════════════════════╝")
	
	for slot_info in info_slots:
		if slot_info["ocupado"]:
			print("\n📁 Slot %d (OCUPADO)" % slot_info["numero"])
			print("   Capítulo: %d" % slot_info["capitulo"])
			print("   Diálogo: %d" % slot_info["dialogo"])
			print("   Fecha: %s" % slot_info["fecha"])
		else:
			print("\n📁 Slot %d (VACÍO)" % slot_info["numero"])


# ============================================================================
# FUNCIÓN: Eliminar todos los datos de un slot
# ============================================================================
func eliminar_slot(numero_slot: int) -> void:
	if slots_manager == null:
		push_error("❌ No se encontró el gestor de slots")
		return
	
	var eliminado = slots_manager.eliminar_slot(numero_slot)
	
	if eliminado:
		print("✓ Slot %d eliminado completamente" % numero_slot)
		# Actualizar la UI
		slots_manager.actualizar_informacion_todos_slots()
	else:
		print("❌ Error al eliminar el slot %d" % numero_slot)


# ============================================================================
# FUNCIÓN: Ejemplo de uso en _process (por si necesitas guardar por evento)
# ============================================================================
func _process(_delta: float) -> void:
	# Ejemplo: Guardar cuando el usuario presiona Ctrl+S
	if Input.is_action_just_pressed("ui_select"):  # Cambiar por tu acción
		guardar_progreso_actual()


# ============================================================================
# EJEMPLO DE FLUJO COMPLETO
# ============================================================================
func ejemplo_flujo_completo() -> void:
	print("\n═══════════════════════════════════════════════")
	print("EJEMPLO DE FLUJO COMPLETO DEL JUEGO")
	print("═══════════════════════════════════════════════\n")
	
	# 1. Mostrar slots disponibles
	mostrar_informacion_slots()
	
	# 2. Simular progreso en el juego
	print("\n→ Iniciando nuevo juego en Capítulo 1...")
	capitulo_actual = 1
	indice_dialogo_actual = 0
	_inicializar_puzzles()
	
	# 3. Avanzar algunos diálogos
	print("\n→ Avanzando diálogos...")
	avanzar_dialogo()
	avanzar_dialogo()
	avanzar_dialogo()
	
	# 4. Completar un puzzle
	print("\n→ Resolviendo puzzle_1...")
	completar_puzzle("puzzle_1")
	
	# 5. Guardar progreso
	print("\n→ Guardando progreso en Slot 1...")
	# Necesitarías seleccionar el slot primero:
	# slots_manager._on_slot_pressed(1)
	# guardar_progreso_actual()
	
	# 6. Mostrar información actualizada
	print("\n→ Información actualizada de slots:")
	mostrar_informacion_slots()


# ============================================================================
# FUNCIONES AUXILIARES DE DEBUG
# ============================================================================
func debug_mostrar_progreso_actual() -> void:
	print("\n╔════════════════════════════════════════╗")
	print("║         PROGRESO ACTUAL EN MEMORIA     ║")
	print("╚════════════════════════════════════════╝")
	print("Capítulo: %d" % capitulo_actual)
	print("Diálogo: %d" % indice_dialogo_actual)
	print("Puzzles:")
	for nombre_puzzle in estado_puzzles:
		var puzzle = estado_puzzles[nombre_puzzle]
		var estado = "✓ COMPLETADO" if puzzle["completado"] else "✗ INCOMPLETO"
		print("  - %s: %s (Intentos: %d)" % [nombre_puzzle, estado, puzzle["intentos"]])


func debug_cargar_slot_1() -> void:
	cargar_slot_especifico(1)
	debug_mostrar_progreso_actual()


func debug_guardar_en_slot_1() -> void:
	# Seleccionar slot 1
	if slots_manager:
		slots_manager._on_slot_pressed(1)
		guardar_progreso_actual()


# ============================================================================
# Llamadas de ejemplo para testing:
# 
# En la consola de Godot puedes probar:
# 
#   $Node.ejemplo_flujo_completo()
#   $Node.mostrar_informacion_slots()
#   $Node.debug_cargar_slot_1()
#   $Node.debug_guardar_en_slot_1()
#   $Node.debug_mostrar_progreso_actual()
#   $Node.avanzar_dialogo()
#   $Node.siguiente_capitulo()
#   $Node.completar_puzzle("puzzle_1")
# ============================================================================
