extends Control

@onready var grid_container = $TextureRect/GridContainer
@onready var pieza_vacia = $TextureRect/GridContainer/TextureButton9
@onready var mensaje_victoria = $MensajeVictoria 

var tamano_pieza = 200
const ORDEN_CORRECTO = [
	"TextureButton",
	"TextureButton2",
	"TextureButton3",
	"TextureButton4",
	"TextureButton5",
	"TextureButton6",
	"TextureButton7",
	"TextureButton8",
	"TextureButton9"
]

func _ready():

	for pieza in grid_container.get_children():
		if pieza is TextureButton:
			pieza.pressed.connect(_on_pieza_pressed.bind(pieza))

func _on_pieza_pressed(pieza_clicada):
	var pos_clic = pieza_clicada.global_position
	var pos_vacia = pieza_vacia.global_position
	var distancia = pos_clic.distance_to(pos_vacia)
	
	if distancia <= tamano_pieza + 5:
		var orden_clic = pieza_clicada.get_index()
		var orden_vacio = pieza_vacia.get_index()
		
		grid_container.move_child(pieza_clicada, orden_vacio)
		grid_container.move_child(pieza_vacia, orden_clic)
		
		verificar_puzzle_completo()


func verificar_puzzle_completo():
	var piezas_actuales = grid_container.get_children()
	
	for i in range(piezas_actuales.size()):
		if piezas_actuales[i].name != ORDEN_CORRECTO[i]:
			return #
			
	resolver_juego()

func resolver_juego():

	mensaje_victoria.visible = true
	
	for pieza in grid_container.get_children():
		if pieza is TextureButton:
			pieza.disabled = true
	
	await get_tree().create_timer(3.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/cap_1.tscn")
