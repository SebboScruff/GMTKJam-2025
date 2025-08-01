class_name CourageBoost
extends Area2D

@export var courage_increase:int

func on_pickup(_player:Player) -> void:
	print("%s picked up by Player"%name)
	# Disable the Area Monitor Status
	# Hide the sprite
	_player.add_wisps(courage_increase)
