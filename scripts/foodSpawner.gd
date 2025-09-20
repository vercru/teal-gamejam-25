extends Node2D

@export var foodScene: PackedScene
@export var spawnTime: float = 2.0

var cameraRect: Rect2
var spawnTimer: float = 0

func _ready() -> void:
	var camera_size = get_viewport_rect().size * get_viewport().get_camera_2d().zoom
	cameraRect = Rect2(- camera_size / 2, camera_size)

func _process(delta: float) -> void:
	spawnTimer -= delta
	if (spawnTimer < 0):
		spawnTimer += spawnTime
		var food: Node2D = foodScene.instantiate()
		food.position = Vector2(
			cameraRect.position.x + cameraRect.size.x / 2 + (randf() * 2 - 1) * cameraRect.size.x * 0.4,
			cameraRect.position.y + cameraRect.size.y / 2 + (randf() * 2 - 1) * cameraRect.size.y * 0.4)
		add_child(food)
