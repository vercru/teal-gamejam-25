extends CharacterBody2D

@export var speed: float = 350.0
@export var move_deadzone: float = 100.0
@export var sprite: Sprite2D
@export var collideScale: float = 1.5
@export var collideScaleAnimationTime: float = 0.2

var spriteOrigScale: Vector2
var scaleTimer: float = 0

func _ready() -> void:
	spriteOrigScale = sprite.scale

func _process(delta: float) -> void:
	sprite.scale = spriteOrigScale * lerp(1.0, collideScale, ease(scaleTimer / collideScaleAnimationTime, -2))
	if (scaleTimer > 0):
		scaleTimer = maxf(0, scaleTimer - delta)

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var global_to_mouse = (mouse_position - global_position);

	if global_to_mouse.length_squared() > move_deadzone:
		var direction = global_to_mouse.normalized()

		velocity = direction * speed
		move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Collision:", collision)
		
		if collision:
			var collider = collision.get_collider()

			if collider is StaticBody2D:
				print("Collided with:", collider.name)
				collider.queue_free()
				scaleTimer = collideScaleAnimationTime
		
		
