extends Control

func _ready() -> void:
	if GameManager.progreso_actual:
		var progreso = GameManager.progreso_actual

		# Iniciar Novi desde el diálogo guardado
		$Dialogos/Novi.iniciar_desde_dialogo(
			int(progreso.get("indice_dialogo", 0)),
			progreso.get("personaje_emocion", "Normal")
	)
	else:
		# Caso nuevo → iniciar desde cero
		$Dialogos/Novi.iniciar()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		$Dialogos/Novi.on_click()
