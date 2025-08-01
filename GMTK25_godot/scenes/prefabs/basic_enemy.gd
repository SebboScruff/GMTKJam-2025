class_name Enemy
extends Area2D

@export var courage_requirement:int = 2

@export var player:Player

@export var map_manager:FogManager
@export var grid:TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	if(player == null):
		print("Player not assigned to enemy %s"%name)
	player.on_player_turn_ended.connect(try_find_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func try_find_player(_current_player_tile:Vector2i) -> void:
	## 1. Search 4 adjacent tiles
	
	## If player is in any of those tiles, attack them
	pass

func attack() -> void:
	# Play attack animation if we have one
	# Immediately reduce the player's Courage by some amount
	# Also darken the map a bit if I get that working.
	pass

func on_death() -> void:
	print("Great Enemy Felled")
	queue_free()
