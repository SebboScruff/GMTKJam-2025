class_name FogManager
extends Node2D

@onready var full_reveal_layer: TileMapLayer = $FullRevealLayer
@onready var half_reveal_layer: TileMapLayer = $HalfRevealLayer
@onready var fog_layer: TileMapLayer = $FogLayer

@export var player:Player

# This is a Vector2i->int Dictionary containing data as to whether a tile in the map has
# been revealed yet.
# NB: Value 0 = Not Revealed, 1 = Half-Revealed, 2 = Full Revealed.
var tile_visibility_matrix:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(player == null):
		print("No Player assigned to the Map's parent object. Fog Management will not work.")
	for i in full_reveal_layer.get_used_cells():
		tile_visibility_matrix[i] = 0
	
	player.on_player_turn_ended.connect(update_fog)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
## This is called whenever the player has finished moving to a tile,
## and passes in their current location in tilemap co-ordinates.
func update_fog(_current_player_tile:Vector2) -> void:
	print("Fog Manager: Player on space (%d, %d)"%[_current_player_tile.x, _current_player_tile.y])
	# 1: Clear Fog
		# Delete all tiles in the FogLayer that are adjacent (inc. diagonal) to the
		# player's tile
	for i in range(-player.vision_range, player.vision_range+1):
		for j in range(-player.vision_range, player.vision_range+1):
			fog_layer.set_cell(Vector2i(_current_player_tile.x+i,_current_player_tile.y+j), -1) # This clears the tile completely
			# Set unreavealed tiles to semi-revealed
			if(tile_visibility_matrix[Vector2i(i,j)] == 0):
				tile_visibility_matrix[Vector2i(i,j)] > 1
	
	# 2: Reveal Adjacent
		# On the 4 orthogonal adjacent tiles to the player, remove the tiles from the HalfReveal Layer
		# as well
	for i in range(-player.vision_range, player.vision_range+1):
		## Fully reveal (and mark in the matrix) for the Horizontal Neighbour Tiles
		half_reveal_layer.set_cell(Vector2i(_current_player_tile.x+i, _current_player_tile.y), -1)
		if(tile_visibility_matrix[Vector2i(_current_player_tile.x+i, _current_player_tile.y)] != 2):
			tile_visibility_matrix[Vector2i(_current_player_tile.x+i, _current_player_tile.y)] = 2
		
		## Likewise for the Vertical Neighbour Tiles.
		half_reveal_layer.set_cell(Vector2i(_current_player_tile.x, _current_player_tile.y+i), -1)
		if(tile_visibility_matrix[Vector2i(_current_player_tile.x, _current_player_tile.y+i)] != 2):
			tile_visibility_matrix[Vector2i(_current_player_tile.x, _current_player_tile.y+i)] = 2
