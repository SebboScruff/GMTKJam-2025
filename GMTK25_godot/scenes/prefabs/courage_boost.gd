class_name CourageBoost
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D


@export var courage_increase:int

func on_pickup(_player:Player) -> void:
	print("%s picked up by Player"%name)
	# Disable the Area Monitor Status
	monitorable = false
	# Hide the sprite
	sprite.set_visible(false)
	_player.add_wisps(courage_increase)
	queue_free()
	
func reset() -> void:
	pass
	# re-enable the Area Monitor Status
	monitorable = true
	# Show the sprite
	sprite.set_visible(true)
