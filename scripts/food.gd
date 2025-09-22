extends Node2D

class_name Food

@export var sprite: Sprite2D
@export var glow: Sprite2D
@export var minRotSpeed: float = 0.2
@export var maxRotSpeed: float = 2.0
@export var moveSpeed: float = 100.0

var rotSpeed: float
var forward: Vector2
var spawnTimer = 1

func _ready() -> void:
	var colour = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0))
	sprite.modulate = colour
	glow.modulate = colour
	sprite.scale *= randf_range(0.8, 1.2)
	rotSpeed = randf_range(minRotSpeed, maxRotSpeed) * (-1 if randi() % 2 == 0 else 1)
	forward = Vector2.RIGHT.rotated(randf() * 2 * PI)

func _process(delta: float) -> void:
	var global_to_camera = get_viewport().get_camera_2d().global_position - global_position
	sprite.rotate(rotSpeed * delta)
	position += forward * delta * moveSpeed
	# despawn
	if (global_to_camera.length_squared() > 1600 * 1600):
		queue_free()
