class_name Player
extends Node2D

const TILE_SIZE := 16

#region External Object References
@export var gm:GameManager
@export var map_manager:FogManager
@export var tilemap:TileMapLayer # This is the fully revealed tilemap, used for determining which tiles can be walked on.

#endregion
#region Internal Object References
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var next_tile_check: RayCast2D = $TileCheckerRaycast
var is_next_tile_occupied:bool = false
#endregion

#region Player Metrics
var courage_remaining:int = 15
var vision_range = 1
#endregion

var is_moving = false
signal on_player_turn_ended(player_tile:Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(gm == null):
		print("No Game Manager Assigned to Player! This may cause lots of issues.")
	if(tilemap == null):
		print("No Tilemap Assigned to player! Movement will not work.")
	
	# Emit this signal once at the start of the game to make sure the Fog updates immediately
	on_player_turn_ended.emit(tilemap.local_to_map(global_position)) 


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
		## This will cause the game manager to run all end-of-turn behaviours
		# HERE we can resolve stuff like picking up items, activating traps, etc etc
		on_player_turn_ended.emit(tilemap.local_to_map(global_position)) 
		
		return
	
	player_sprite.global_position = player_sprite.global_position.move_toward(global_position, 1)
	
	
func try_move(direction:Vector2):
	next_tile_check.target_position = direction * TILE_SIZE
	next_tile_check.force_raycast_update()
	
	# Get current world position as grid coords
	var current_tile:Vector2i = tilemap.local_to_map(global_position)
	
	# Get next tile in target direction as grid coords
	var target_tile:Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	## If next occupied by enemy, do a combat check
	if(next_tile_check.is_colliding()):
		if(next_tile_check.get_collider() is Enemy):
			resolve_combat(next_tile_check.get_collider() as Enemy, current_tile, target_tile)
			return
	
	var target_tile_data:TileData = tilemap.get_cell_tile_data(target_tile)
	# If unoccupied but not walkable, don't move
	if(target_tile_data.get_custom_data("Walkable") == false):
		return
		
	## Need to flag if the next tile is unrevealed or half-revealed
	## If it is, then moving into it will cost Courage, and you cannot move into it
	## if you are out of Courage.
	var is_next_tile_scary:bool = false
	if(map_manager.tile_visibility_matrix[target_tile] != 2):
		is_next_tile_scary = true
	
	# If unoccupied and walkable, move.
	if(is_next_tile_scary && courage_remaining <= 0):
		##TODO Play some animation here where the kid is scared
		return
	else:
		move_to_tile(current_tile, target_tile)
		adjust_courage(-1)

func resolve_combat(target_enemy:Enemy, _current_tile:Vector2, _target_tile:Vector2) -> void:
	print(target_enemy.name)
	if(courage_remaining > target_enemy.courage_requirement):
		target_enemy.on_death()
		move_to_tile(_current_tile, _target_tile)
		return
	elif(courage_remaining == target_enemy.courage_requirement):
		target_enemy.on_death()
		move_to_tile(_current_tile, _target_tile)
		adjust_courage(-1) ## Numbers subject to change
		return
	elif(courage_remaining < target_enemy.courage_requirement):
		## Probably want some kind of animation or infomatic to show that you lost
		adjust_courage(-1) ## Numbers subject to change
		return
	

func move_to_tile(current_tile:Vector2, target_tile:Vector2):
	is_moving = true
	# Move the player object forward, leaving the visual sprite behind to catch up a little bit
	# Hacky way to animate movement
	## check _physics_process for sprite movement details
	global_position = tilemap.map_to_local(target_tile)
	player_sprite.global_position = tilemap.map_to_local(current_tile)

func adjust_courage(_delta:int) -> void:
	force_cancel_movement()
	courage_remaining += _delta
	print("You have %d courage remaining"%courage_remaining)
	if(courage_remaining <= 0):
		print("bleh")
		## TODO Respawn behaviours

func force_cancel_movement() -> void:
	Input.action_release("move_up")
	Input.action_release("move_down")
	Input.action_release("move_left")
	Input.action_release("move_right")
