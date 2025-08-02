class_name CourageBoost
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var courage_increase:int
var visual_wisps = []

func _ready() -> void:
	for c in get_children():
		if(c is CourageWisp):
			visual_wisps.append(c)

func on_pickup(_player:Player) -> void:
	print("%s picked up by Player"%name)
	# Disable the Area Monitor Status
	collision_shape_2d.disabled = true
	# Hide the sprite
	sprite.set_visible(false)
	_player.add_wisps(courage_increase)
	for w in visual_wisps:
		w.set_visible(false)
	
func reset() -> void:
	# re-enable the collider
	collision_shape_2d.disabled = false
	# Show the sprite
	sprite.set_visible(true)
	for w in visual_wisps:
		w.set_visible(true)
