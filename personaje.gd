extends CharacterBody2D

var velocidad = 200
var objetivo = null
var jugador_adentro = false

func _process(delta):
	var moviendose = false 
	
	if jugador_adentro == true and objetivo != null:
		var distancia = global_position.distance_to(objetivo.global_position)
		
		if distancia > 50:
			var direccion = (objetivo.global_position - global_position).normalized()
			velocity = direccion * velocidad
			move_and_slide()
			
			moviendose = true 

	if moviendose == true:
		$AnimatedSprite2D.play("caminar")
	else:

		velocity.x = 0
		velocity.y = 0
		$AnimatedSprite2D.play("default")
func _on_area_2d_body_entered(body):
	if body.name == "prota":
		objetivo = body
		jugador_adentro = true


func _on_area_2d_body_exited(body):
	if body.name == "prota":
		jugador_adentro = false 
