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
var tiles_visited:Array = []
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
	#on_player_turn_ended.emit(tilemap.local_to_map(global_position)) 
	tiles_visited.append(get_current_tile())
	print("Player started on Tile (%d,%d)"%[get_current_tile().x, get_current_tile().y])


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
		if(!tiles_visited.has(get_current_tile())):
			tiles_visited.append(get_current_tile())
			print("Player has visited Tile (%d,%d)"%[get_current_tile().x, get_current_tile().y])
		## This will cause the game manager to run all end-of-turn behaviours
		# HERE we can resolve stuff like picking up items, activating traps, etc etc
		on_player_turn_ended.emit(tilemap.local_to_map(global_position)) 
		
		return
	
	player_sprite.global_position = player_sprite.global_position.move_toward(global_position, 1)
	
	
func try_move(direction:Vector2):
	## First, change the direction of the raycast so it's facing in the direction
	## that the player is about to move in.
	next_tile_check.target_position = direction * TILE_SIZE
	next_tile_check.force_raycast_update()
	
	## Get current world position as tilemap coords
	var current_tile:Vector2i = tilemap.local_to_map(global_position)
	
	## Get next tile in target direction as grid coords
	var target_tile:Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	
	## If next occupied by enemy, do a combat check
	if(next_tile_check.is_colliding()):
		if(next_tile_check.get_collider() is Enemy):
			resolve_combat(next_tile_check.get_collider() as Enemy, current_tile, target_tile)
			return # Whether or not we move is determined by the combat function. Break out of try_move.
	
	## Extract data out of the target tile, to see if it is walkable or not
	var target_tile_data:TileData = tilemap.get_cell_tile_data(target_tile)
	# If unoccupied but not walkable (i.e. Obstacle spaces, don't move
	if(target_tile_data.get_custom_data("Walkable") == false):
		return
		
	## Need to check if the next tile has previously been visited.
	## If it hasn't, then moving there will have a courage cost.
	print("Player Movement: Target Tile is (%d,%d)"%[target_tile.x, target_tile.y])
	var is_next_tile_unvisited:bool = true
	if(tiles_visited.has(target_tile)):
		print("Player Movement: Target Tile has been visited")
		is_next_tile_unvisited = false
	
	if(is_next_tile_unvisited):
		if(courage_remaining > 0):
			move_to_tile(current_tile, target_tile)
			adjust_courage(-1)
		else: ## tile is unvisited and there's no courage left
			print("You aren't brave enough to continue")
			##TODO Play an animation here to show that he's too scared to go on
			return
	else: # Next tile has already been visited
		move_to_tile(current_tile, target_tile)

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
	print("Courage Updated: You have %d courage remaining"%courage_remaining)
	if(courage_remaining <= 0):
		print("Player has died")
		## TODO Respawn behaviours

func force_cancel_movement() -> void:
	Input.action_release("move_up")
	Input.action_release("move_down")
	Input.action_release("move_left")
	Input.action_release("move_right")
	
func get_current_tile() -> Vector2i:
	return tilemap.local_to_map(global_position)
