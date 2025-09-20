extends CharacterBody2D

@export var speed: float = 350.0
@export var move_deadzone: float = 100.0

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var global_to_mouse = (mouse_position - global_position);

	if global_to_mouse.length_squared() > move_deadzone:
		var direction = (mouse_position - global_position).normalized()

		velocity = direction * speed
		move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Collision:", collision)
		
		if collision:
			var collider = collision.get_collider()

			if collider is StaticBody2D:
				print("Collided with:", collider.name)
				scale = Vector2(1.5, 1.5)
			
				await get_tree().create_timer(0.1).timeout
				scale = Vector2(1, 1)
		
		
