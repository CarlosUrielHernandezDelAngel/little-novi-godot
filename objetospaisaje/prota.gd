extends CharacterBody2D

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	var direccion := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direccion * 200
	move_and_slide()
	
	
	if animacion:
		if direccion != Vector2.ZERO:
			
			animacion.play("caminar")
			
			
			if direccion.x < 0:
				animacion.flip_h = true  
			elif direccion.x > 0:
				animacion.flip_h = false 
		else:
			
			animacion.play("default")
