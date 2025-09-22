extends StaticBody2D

class_name HeroBodyPiece

@export var sprite: Sprite2D

var prevPosition: Vector2
var scaleTimer: float = 0
var _animationTime: float
var animationScaleSize: float
var spriteOrigScale: Vector2
var child: StaticBody2D

func _ready() -> void:
	prevPosition = global_position
	spriteOrigScale = sprite.scale

func _process(delta: float) -> void:
	var parentGlobalPos = get_parent().global_position
	global_position = lerp(prevPosition, parentGlobalPos, delta * 8)
	prevPosition = global_position
	look_at(parentGlobalPos)

	sprite.scale = spriteOrigScale * lerp(1.0, animationScaleSize, ease(scaleTimer / _animationTime, -2))
	if (scaleTimer > 0):
		var prev = scaleTimer
		scaleTimer = maxf(0, scaleTimer - delta)
		if prev > _animationTime / 2 and scaleTimer <= _animationTime / 2 and child != null:
			child.boop(_animationTime, animationScaleSize)

func boop(animationTime: float, boopSize: float) -> void:
	_animationTime = animationTime
	scaleTimer = animationTime
	animationScaleSize = boopSize
