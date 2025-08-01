class_name Enemy
extends Area2D

@export var fear_level:int = 2

@export var player:Player

@export var map_manager:FogManager
@export var tilemap:TileMapLayer

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
	var tiles_to_search = [
		get_current_tile() + Vector2i(1,0),
		get_current_tile() + Vector2i(-1,0),
		get_current_tile() + Vector2i(0,1),
		get_current_tile() + Vector2i(0,-1)]
	## If player is in any of those tiles, attack them
	for t in tiles_to_search:
		if(player.get_current_tile() == t):
			# Round player courage up to get the number of wisps that they have. 
			var player_wisp_count = ceil(player.courage_remaining)
			print("Player is getting attacked by %s"%name)
			# Check based on this enemy's Fear level?
			# Then deal some amount of damage to the player
			# and Fog up the map
			## TODO First up play the attack animation
			if(player.player_wisp_count == 0):
				## Player dies, this run is over.
				pass
			elif(player.player_wisp_count > fear_level):
				## Player takes no damage and does not black out.
				pass
			elif (player.player_wisp_count == fear_level):
				## player loses 1 Courage, but does not black out.
				pass
			elif(player.player_wisp_count < fear_level):
				## Player loses 1 Courage AND blacks out.
				pass
			return # Player has been located, don't need to search remaining neighbour tiles.

func attack() -> void:
	# Play attack animation if we have one
	# Immediately reduce the player's Courage by some amount
	# Also darken the map a bit if I get that working.
	pass

func get_current_tile() -> Vector2i:
	return tilemap.local_to_map(self.global_position)

func on_death() -> void:
	print("Great Enemy Felled")
	queue_free()
