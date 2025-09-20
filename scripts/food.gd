extends Node2D

@export var sprite: Sprite2D
@export var glow: Sprite2D
@export var minRotSpeed: float = 0.2
@export var maxRotSpeed: float = 2.0

var rotSpeed: float
var forward: Vector2

func _ready() -> void:
	var colour = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0))
	sprite.modulate = colour
	glow.modulate = colour
	sprite.scale *= randf_range(0.8, 1.2)
	rotSpeed = randf_range(minRotSpeed, maxRotSpeed) * (-1 if randi() % 2 == 0 else 1)
	var forwardAngle = randf() * 2 * PI
	forward = Vector2(cos(forwardAngle), sin(forwardAngle))

func _process(delta: float) -> void:
	sprite.rotate(rotSpeed * delta)
	position += forward * delta * 10
