class_name FogManager
extends Node2D

## These are the tiles that the player has already exactly stepped on
@onready var full_reveal_layer: TileMapLayer = $FullRevealLayer 
## These are directly adjacent to the player's visited tiles. Reveals Enemies.
@onready var quarter_reveal_layer: FogMap = $QuarterRevealLayer
## These are 2 spaces out from where the player has been. Reveals items/terrain, hides enemies
@onready var half_reveal_layer: FogMap = $HalfRevealLayer
## The whole map starts on this. Completely hides everything.
@onready var fog_layer: FogMap = $FogLayer

@export var player:Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(player == null):
		print("No Player assigned to the Map's parent object. Fog Management will not work.")

	
	player.on_player_turn_ended.connect(update_fog)
	update_fog(player.get_current_tile()) # Call Update Fog immediately 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("debug_activate")):
		reset_fog_completely()
	pass
	
## This is called whenever the player has finished moving to a tile,
## and passes in their current location in tilemap co-ordinates.
## Basically what happens here is the tilemaps for each fog layer are keeping a big list of
## what opacity each tile should be (either 0 or 1 for transparent or opaque).
## when the player moves, different tiles on different layers need to be cleared to give
## the impression that the fog is lifting. This is performatively pretty expensive, especially as
## the map gets bigger, but its probably the most straightforward way of making the change reversible.
func update_fog(_current_player_tile:Vector2i) -> void:
	print("Fog Manager: Player on space (%d, %d)"%[_current_player_tile.x, _current_player_tile.y])
	# Player's tile needs to be cleared of all fog
	#fog_layer.set_cell(_current_player_tile, -1)
	fog_layer.tile_alpha_values[_current_player_tile] = 0
	#half_reveal_layer.set_cell(_current_player_tile, -1)
	half_reveal_layer.tile_alpha_values[_current_player_tile] = 0
	#quarter_reveal_layer.set_cell(_current_player_tile, -1)
	quarter_reveal_layer.tile_alpha_values[_current_player_tile] = 0
	
	# 4 Adjacent Spaces to player's tile need to be cleared of Full + Half Fog, leaving 1/4
	var tiles_to_quarter = [
		_current_player_tile + Vector2i(1,0),
		_current_player_tile + Vector2i(-1,0),
		_current_player_tile + Vector2i(0,1),
		_current_player_tile + Vector2i(0,-1)]
	for t in tiles_to_quarter:
		#fog_layer.set_cell(t, -1)
		fog_layer.tile_alpha_values[t] = 0
		#half_reveal_layer.set_cell(t, -1)
		half_reveal_layer.tile_alpha_values[t] = 0
	
	# Outer Diamond needs to be cleared of Full Fog only, leaving Half-Fog
	var tiles_to_half = [
		_current_player_tile + Vector2i(2,0),
		_current_player_tile + Vector2i(-2,0),
		_current_player_tile + Vector2i(0,2),
		_current_player_tile + Vector2i(0,-2),
		_current_player_tile + Vector2i(1,1),
		_current_player_tile + Vector2i(-1,1),
		_current_player_tile + Vector2i(1,-1),
		_current_player_tile + Vector2i(-1,-1)]
	
	for t in tiles_to_half:
		#fog_layer.set_cell(t, -1)
		fog_layer.tile_alpha_values[t] = 0
		
	# This is gonna get pretty expensive if the map gets really big.
	# Ultimately if this game does get continued the whole fog system will have to be redone
	# using shaders and stuff to be much more performative.
	fog_layer.notify_runtime_tile_data_update()
	half_reveal_layer.notify_runtime_tile_data_update()
	quarter_reveal_layer.notify_runtime_tile_data_update()
	

func reset_fog_completely() -> void:
	print("Fog Manager: Resetting Fog...")
	# 1: Reset tile opacity on every tilemap layer
	# reset_opacities() is a function that goes through every entry in the dictionary of 
	# tiles and sets the alpha back to 1.
	fog_layer.reset_opacities()
	half_reveal_layer.reset_opacities()
	quarter_reveal_layer.reset_opacities()
	
	#2: Clear the player's Visited Tiles.
	player.on_map_fog_reset()
	#3: Run Update Fog on the player's current location
	update_fog(player.get_current_tile())
