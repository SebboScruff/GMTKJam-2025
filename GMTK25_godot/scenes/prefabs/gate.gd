class_name ExitGate
extends Area2D

const TOTEMS_NEEDED := 2
var is_open := false

@onready var closed_sprite: Sprite2D = $ClosedSprite
@onready var open_sprite: Sprite2D = $OpenSprite
@onready var sfx_open_door: AudioStreamPlayer2D = $SFX_OpenDoor

func check_player_totem_count(_player:Player) -> void:
	print("Player has found %d totems"%_player.totems_found)
	if(_player.totems_found >= TOTEMS_NEEDED):
		on_open()

# Called when the node enters the scene tree for the first time.
func on_open() -> void:
	is_open = true
	sfx_open_door.play()
	closed_sprite.set_visible(false)
	open_sprite.set_visible(true)
	
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, true)
