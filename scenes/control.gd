extends Control

@export var hero_scene: PackedScene

@onready var start_button = $StartButton
@onready var camera = get_node("../Camera2D")
@onready var game_root = get_node("../../gameRoot")

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	print("PNG button clicked!")
	var hero = hero_scene.instantiate()
	game_root.add_child(hero)

	start_button.visible = false
