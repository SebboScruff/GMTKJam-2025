class_name Totem
extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var inactive_sprite: Sprite2D = $InactiveSprite
@onready var active_sprite: Sprite2D = $ActiveSprite

func _ready() -> void:
	inactive_sprite.set_visible(true)
	active_sprite.set_visible(false)

func on_activate(_player:Player) -> void:
	print("%s picked up by Player"%name)
	# Disable the Area Monitor Status
	collision_shape_2d.disabled = true
	# Hide the sprite
	inactive_sprite.set_visible(false)
	active_sprite.set_visible(true)
	_player.totems_found += 1
