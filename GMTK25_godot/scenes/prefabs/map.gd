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
		reset_fog()
	pass
	
## This is called whenever the player has finished moving to a tile,
## and passes in their current location in tilemap co-ordinates.
func update_fog(_current_player_tile:Vector2i) -> void:
	print("Fog Manager: Player on space (%d, %d)"%[_current_player_tile.x, _current_player_tile.y])
	# Player's tile needs to be cleared of all fog
	fog_layer.set_cell(_current_player_tile, -1)
	half_reveal_layer.set_cell(_current_player_tile, -1)
	quarter_reveal_layer.set_cell(_current_player_tile, -1)
	
	# 4 Adjacent Spaces to player's tile need to be cleared of Full + Half Fog, leaving 1/4
	var tiles_to_quarter = [
		_current_player_tile + Vector2i(1,0),
		_current_player_tile + Vector2i(-1,0),
		_current_player_tile + Vector2i(0,1),
		_current_player_tile + Vector2i(0,-1)]
	for t in tiles_to_quarter:
		fog_layer.set_cell(t, -1)
		half_reveal_layer.set_cell(t, -1)
	
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
		var target_tile = _current_player_tile + t
		fog_layer.set_cell(t, -1)
	

func reset_fog() -> void:
	#1: Reset tile opacity on every tilemap layer
	#2: Run Update Fog on the player's current location
	pass
