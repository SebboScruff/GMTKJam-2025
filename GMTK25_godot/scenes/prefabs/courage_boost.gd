class_name CourageBoost
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


@export var courage_increase:int

func on_pickup(_player:Player) -> void:
	print("%s picked up by Player"%name)
	# Disable the Area Monitor Status
	collision_shape_2d.disabled = true
	# Hide the sprite
	sprite.set_visible(false)
	_player.add_wisps(courage_increase)
	
func reset() -> void:
	# re-enable the collider
	collision_shape_2d.disabled = false
	# Show the sprite
	sprite.set_visible(true)
