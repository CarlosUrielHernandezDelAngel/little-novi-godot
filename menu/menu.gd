extends Control
@onready var inicio_button: Button = $VBoxContainer/inicio
@onready var acercade_button: Button = $VBoxContainer/acercade
@onready var slots_button: Button = $VBoxContainer/Guardados
@onready var mi_panel: Panel = $Panel
@onready var cerrar_button: Button = $Panel/Button

func _ready() -> void:
	inicio_button.pressed.connect(_on_inicio_pressed)
	acercade_button.pressed.connect(_on_acercade_pressed)
	cerrar_button.pressed.connect(_on_cerrar_pressed)
	slots_button.pressed.connect(_on_slots_pressed)

func _on_inicio_pressed() -> void:
	GameManager.iniciar_nueva_partida()
	get_tree().change_scene_to_file("res://scenes/cap_1.tscn")

func _on_acercade_pressed() -> void:
	if mi_panel:
		mi_panel.show()

func _on_cerrar_pressed() -> void:
	if mi_panel:
		mi_panel.hide()

func _on_slots_pressed() -> void:
	GameManager.establecer_accion_pendiente("cargar")
	print("Acción establecida: cargar")
	get_tree().change_scene_to_file("res://menu/slots.tscn")
