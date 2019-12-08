extends StaticBody2D

@onready var zona_interaccion = $Area2D
@onready var sprite_animal = $SpriteAnimal
@onready var corazon_ui = $TextoCorazon
@onready var dialogo_ui = $TextoDialogo

var jugador_cerca = false
var ya_acariciado = false

func _ready():
	corazon_ui.visible = false
	dialogo_ui.visible = false
	sprite_animal.play("idle")
	
	# Esto conecta el toque del dedo automáticamente sin usar el editor
	zona_interaccion.input_event.connect(_on_area_2d_input_event)

# Reemplazamos el _process por esta función que detecta el toque táctil
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Revisa si el jugador tocó la pantalla con el dedo
	if event is InputEventScreenTouch and event.pressed:
		# Si el prota está cerca y aún no lo acaricias, activa la animación
		if jugador_cerca and not ya_acariciado:
			hacer_caricias()

func hacer_caricias():
	ya_acariciado = true
	dialogo_ui.visible = false  
	corazon_ui.visible = true   
	sprite_animal.play("feliz")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "jugador" in body.name.to_lower() or "prota" in body.name.to_lower():
		jugador_cerca = true
		if not ya_acariciado:
			dialogo_ui.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if "jugador" in body.name.to_lower() or "prota" in body.name.to_lower():
		jugador_cerca = false
		dialogo_ui.visible = false
		corazon_ui.visible = false
		sprite_animal.play("idle")
		ya_acariciado = false
