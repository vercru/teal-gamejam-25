extends Node2D

@export var foodScene: PackedScene
@export var spawnTime: float = 2.0

var spawnTimer: float = 0

func _process(delta: float) -> void:
	spawnTimer -= delta
	if (spawnTimer < 0):
		spawnTimer += spawnTime
		var centerPos = get_viewport().get_camera_2d().global_position
		var angle = randf_range(0, PI * 2)
		var distance = randf_range(400, 800)
		var spawnPos = Vector2(distance, 0).rotated(angle) + centerPos

		var food: Node2D = foodScene.instantiate()
		food.position = spawnPos
		add_child(food)
