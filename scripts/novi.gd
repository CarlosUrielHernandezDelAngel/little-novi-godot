extends Control

# ─── Referencias ───────────────────────────────────────────────
@onready var dialogue_label  = $saludo              # RichTextLabel para texto
@onready var name_label      = $"../Nombres/CajaNombre"  # Label para nombre del hablante
@onready var character_node  = $"../../Personajes/Novi" # Sprite del personaje
var tween: Tween = null

# ─── Datos de diálogo ──────────────────────────────────────────
var dialogos = [
	{"speaker": "Novi", "texto": "¿Hoy es un bonito dia no…?", "expresion": "Normal"},
	{"speaker": "Copito", "texto": ".... :)", "expresion": "Panic"},
	{"speaker": "Novi", "texto": "Vamos, podrías decir algo al menos.", "expresion": "Bored"},
	{"speaker": "Copito", "texto": ".... :)", "expresion": "Panic"},
	{"speaker": "Novi", "texto": "Bueno… tal vez debería dejar de intentar hablar con un gato. Regresemos a casa.", "expresion": "Bored"},
	{"accion": "mapa"},  # Transición a mapa.tscn
	{"speaker": "Novi", "texto": "Si todo sale bien, tendremos lo suficiente para el invierno.", "expresion": "Normal"},
	{"speaker": "Copito", "texto": ".... :)", "expresion": "Panic"},
	{"speaker": "Novi", "texto": "Aunque… si me esfuerzo el doble, quizá consiga unas latas de atún en la ciudad.", "expresion": "Normal"},
	{"speaker": "Copito", "texto": ":3", "expresion": "Panic"},
	{"speaker": "Novi", "texto": "¡Ya sé! Hace poco compré un rompecabezas de la ciudad. ¿Qué tal si lo armamos juntos?", "expresion": "Nervous"},
	{"speaker": "Copito", "texto": ".... :D", "expresion": "Panic"},
	{"accion": "rompecabezas"},  # Transición a puzzle.tscn
	{"speaker": "Novi", "texto": "¡Y listo!", "expresion": "Normal"},
	{"speaker": "Copito", "texto": ":D :D", "expresion": "Panic"},
	{"speaker": "Novi", "texto": "Hay días en los que pienso que las cosas podrían haber salido peor… pero tú estás aquí, y con eso basta.", "expresion": "Bored"},
	{"speaker": "Copito", "texto": ":D", "expresion": "Panic"}
]

# ─── Estado interno ────────────────────────────────────────────
var indice: int = 0
var full_text: String = ""
var char_index: int = 0
var velocidad_texto: float = 0.05
var escribiendo: bool = false
var esperando_click: bool = false

# ─── Inicialización ────────────────────────────────────────────
func iniciar():
	indice = GameManager.indice_dialogo   # Recuperar progreso guardado
	if indice < dialogos.size():
		_mostrar_linea_actual()

func iniciar_desde_dialogo(indice_guardado: int, emocion: String):
	indice = indice_guardado
	if indice < dialogos.size():
		_mostrar_linea_actual()
	_set_expression(emocion)


# ─── Entrada de usuario ────────────────────────────────────────
func on_click():
	if escribiendo:
		_skip_texto()
	elif esperando_click:
		indice += 1
		GameManager.actualizar_dialogo(indice)   # Actualizar progreso global
		if indice < dialogos.size():
			_mostrar_linea_actual()
		else:
			_fin_dialogo()

# ─── Mostrar diálogo ───────────────────────────────────────────
func _mostrar_linea_actual():
	var d = dialogos[indice]

	if d.has("accion"):
		_ejecutar_accion(d["accion"])
		return
	
	if name_label:
		name_label.text = d["speaker"]
		
	var linea = "- %s" % d["texto"]
	
	_set_expression(d["expresion"])
	_animar_texto(dialogue_label, linea)

# ─── Acciones especiales ───────────────────────────────────────
func _ejecutar_accion(tipo: String):
	print("Ejecutando acción especial: ", tipo)
	
	indice += 1
	GameManager.actualizar_dialogo(indice)
	
	match tipo:
		"mapa":
			get_tree().change_scene_to_file("res://mundo/escenario1.tscn")
		"rompecabezas":
			get_tree().change_scene_to_file("res://rompecabezas/rompecabezas.tscn")
		_:
			print("Acción desconocida: ", tipo)

# ─── Animación de texto ────────────────────────────────────────
func _animar_texto(label, texto: String):
	full_text = texto
	char_index = 0
	label.text = ""
	escribiendo = true
	esperando_click = false

	if tween:
		tween.kill()
	tween = create_tween()

	for i in range(full_text.length()):
		tween.tween_callback(Callable(self, "_append_letter")).set_delay(velocidad_texto * i)

	tween.tween_callback(Callable(self, "_on_texto_completo")).set_delay(velocidad_texto * full_text.length())

func _append_letter():
	if char_index < full_text.length():
		dialogue_label.text += full_text[char_index]
		char_index += 1

func _on_texto_completo():
	escribiendo = false
	esperando_click = true

func _skip_texto():
	if tween:
		tween.kill()
	dialogue_label.text = full_text
	char_index = full_text.length()
	escribiendo = false
	esperando_click = true

# ─── Expresiones del personaje ─────────────────────────────────
func _set_expression(expresion: String):
	if expresion == "":
		return
	var path := ""
	match expresion:
		"Bored":   path = "res://assets/personaje/AnimationSheet_Character (2).png"
		"Nervious": path = "res://assets/personaje/AnimationSheet_Character (3).png"
		"Normal":  path = "res://assets/personaje/AnimationSheet_Character (1).png"
		"Panic":   path = "res://assets/gato/CAT BASE_1.png"
		_: return

	var tex = load(path)
	if tex:
		character_node.texture = tex
		character_node.scale = Vector2(9.0, 9.0)

# ─── Fin del diálogo ───────────────────────────────────────────
func _fin_dialogo():
	print("Fin del diálogo del capítulo.")
	get_tree().change_scene_to_file("res://menu/final.tscn")
	# Aquí puedes emitir una señal o cambiar de escena
