class_name Player
extends Node2D

const TILE_SIZE := 16

#region External Object References
@export var gm:GameManager
@export var tilemap:TileMapLayer
#endregion
#region Internal Object References
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var next_tile_check: RayCast2D = $TileCheckerRaycast
#endregion

#region Player Metrics
#endregion

var is_moving = false
signal player_turn_ended

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(gm == null):
		print("No Game Manager Assigned to Player! This may cause lots of issues.")
	if(tilemap == null):
		print("No Tilemap Assigned to player! Movement will not work.")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if(gm.can_player_act == false):
		#return
	if(is_moving):
		return
		
	if(Input.is_action_pressed("move_up")):
		next_tile_check.target_position = Vector2(0, -TILE_SIZE)
		try_move(Vector2.UP)
	elif (Input.is_action_pressed("move_down")):
		next_tile_check.target_position = Vector2(0, TILE_SIZE)
		try_move(Vector2.DOWN)
	elif(Input.is_action_pressed("move_left")):
		next_tile_check.target_position = Vector2(-TILE_SIZE,0)
		try_move(Vector2.LEFT)
	elif(Input.is_action_pressed("move_right")):
		next_tile_check.target_position = Vector2(TILE_SIZE,0)
		try_move(Vector2.RIGHT)
		


func _physics_process(delta: float) -> void:
	if(is_moving == false):
		return
		
	if(global_position == player_sprite.global_position):
		is_moving = false
		player_turn_ended.emit ## This will cause the game manager to run all end-of-turn behaviours
		return
	
	player_sprite.global_position = player_sprite.global_position.move_toward(global_position, 1)
	
	
func try_move(direction:Vector2):
	# Get currently occupied tile
	var current_tile:Vector2i = tilemap.local_to_map(global_position)
	
	var target_tile:Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	# Check if this tile is currently free!
	# If occupied by enemy, do a combat check
	# (this will be done by a raycast most likely)
	var target_tile_data:TileData = tilemap.get_cell_tile_data(target_tile)
	# If unoccupied but not walkable, don't move
	if(target_tile_data.get_custom_data("Walkable") == false):
		return
		
	# If unoccupied and walkable, move.
	is_moving = true
	# Move the player object forward, leaving the visual sprite behind to catch up a little bit
	# Hacky way to animate movement
	## check _physics_process for sprite movement details
	global_position = tilemap.map_to_local(target_tile)
	player_sprite.global_position = tilemap.map_to_local(current_tile)
	
	print(current_tile)
	print(target_tile)
