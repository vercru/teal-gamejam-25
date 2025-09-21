extends CharacterBody2D

@export var speed: float = 350.0
@export var moveDeadzone: float = 100.0
@export var sprite: Sprite2D
@export var collideScale: float = 1.5
@export var collideScaleAnimationTime: float = 0.2
@export var headNode: Node2D
@export var bodyPieceScene: PackedScene

var spriteOrigScale: Vector2
var scaleTimer: float = 0
var tailNode: Node2D
var firstChild: Node2D

func _ready() -> void:
	spriteOrigScale = sprite.scale
	tailNode = headNode;

func _process(delta: float) -> void:
	sprite.scale = spriteOrigScale * lerp(1.0, collideScale, ease(scaleTimer / collideScaleAnimationTime, -2))
	if (scaleTimer > 0):
		var prev = scaleTimer
		scaleTimer = maxf(0, scaleTimer - delta)
		if prev > collideScaleAnimationTime / 2 and scaleTimer <= collideScaleAnimationTime / 2:
			firstChild.boop(collideScaleAnimationTime, collideScale)
			
	look_at(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var global_to_mouse = (mouse_position - global_position);

	if global_to_mouse.length_squared() > moveDeadzone:
		var direction = global_to_mouse.normalized()

		velocity = direction * speed
		move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		if collision:
			var collider = collision.get_collider()

			if collider is StaticBody2D:
				#multiple collision hits within 1 frame can happen due to a bug in the physics engine: https://github.com/godotengine/godot/issues/98353
				if collider.collision_layer == 0:
					continue

				var colour = get_first_sprite2d(collider).modulate
				var newTailNode = bodyPieceScene.instantiate()
				get_first_sprite2d(newTailNode).modulate = colour
				tailNode.add_child(newTailNode)
				tailNode.move_child(newTailNode, 0)
				if tailNode != headNode: tailNode.child = newTailNode
				tailNode = newTailNode
				if firstChild == null: firstChild = newTailNode

				collider.collision_layer = 0
				collider.queue_free()
				scaleTimer = collideScaleAnimationTime

func get_first_sprite2d(node: Node) -> Sprite2D:
	for child in node.get_children():
		if child is Sprite2D:
			return child
		var sprite = get_first_sprite2d(child)
		if sprite:
			return sprite
	return null
