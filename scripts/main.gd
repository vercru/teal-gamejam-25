extends Node2D

func _ready():
	var label = Label.new()
	label.text = "Hello, Godot!"
	label.position = Vector2(200, 100)
	label.z_index = -1

	add_child(label)

	var sprite = Sprite2D.new()
	var texture = preload("res://assets/icon.svg")
	sprite.texture = texture
	sprite.position = Vector2(200, 200)
	sprite.z_index = -1

	add_child(sprite)
