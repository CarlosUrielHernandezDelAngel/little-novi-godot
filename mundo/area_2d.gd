extends Area2D

func _on_body_entered(body):
	# Comprobamos si lo que tocó la puerta es tu personaje principal
	if body.name == "jugador":
		# ¡Aquí hacemos el cambio de pantalla!
		get_tree().change_scene_to_file("res://interior_casa.tscn")
