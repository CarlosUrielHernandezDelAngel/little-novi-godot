extends Area2D

func _on_body_entered(body):
	if body.name == "prota":

		get_tree().change_scene_to_file("res://scenes/cap_1.tscn")
