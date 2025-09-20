extends Node2D

@export var sprite: Sprite2D
@export var glow: Sprite2D
@export var minRotSpeed: float = 0.2
@export var maxRotSpeed: float = 2.0
@export var moveSpeed: float = 200.0

var rotSpeed: float
var forward: Vector2
var cameraRect: Rect2
var spawnTimer = 1

func _ready() -> void:
	var colour = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0))
	sprite.modulate = colour
	glow.modulate = colour
	sprite.scale *= randf_range(0.8, 1.2)
	rotSpeed = randf_range(minRotSpeed, maxRotSpeed) * (-1 if randi() % 2 == 0 else 1)
	forward = (-position.rotated((randf() * 2 - 1) * PI / 2)).normalized()
	var camera_size = get_viewport_rect().size * get_viewport().get_camera_2d().zoom
	cameraRect = Rect2(- camera_size / 2 * 1.1, camera_size * 1.1)

func _process(delta: float) -> void:
	sprite.rotate(rotSpeed * delta)
	position += forward * delta * moveSpeed
	if (!cameraRect.has_point(position)):
		queue_free()
