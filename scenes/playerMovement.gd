extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()
