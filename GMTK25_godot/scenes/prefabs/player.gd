class_name Player
extends Node2D

const TILE_SIZE := 512
const RESPAWN_TILE := Vector2i(-1,0)

#region External Object References
@export var gm:GameManager
@export var map_manager:FogManager
@export var tilemap:TileMapLayer # This is the fully revealed tilemap, used for determining which tiles can be walked on.
@export var pickup_respawner:PickupRespawner
@export var gate:ExitGate
#endregion
#region Internal Object References
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var player_anim_sprite: AnimatedSprite2D = $PlayerAnimSprite
@onready var next_tile_check: RayCast2D = $TileCheckerRaycast
var is_next_tile_occupied:bool = false
@onready var wisp_manager: WispManager = %CourageWisps
#endregion

#region Animation Signals
var anim_direction:int

signal anim_is_moving(dir:int)
signal anim_return_to_idle
signal anim_is_too_scared
signal anim_died
signal anim_attack(dir:int)
#endregion

#region Player Metrics
var movement_speed := 30
var courage_remaining:float = 0.0
var recent_blackout:=false
# The tiles discovered during an expedition. Tiles in this array can be lost for good.
var tiles_visited:Array = []
# Upon returning to the village, tiles are saved in here and cannot be lost on death.
# The next run will start with all of these still available.
var tiles_recorded:Array = []
var totems_found := 0
#endregion

var lost_combat := false
var is_moving := false
var is_dead := false
signal on_player_turn_ended(player_tile:Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(gm == null):
		print("No Game Manager Assigned to Player! This may cause lots of issues.")
	if(map_manager == null):
		print("No Map Manager assigned to Player!")
	tilemap = map_manager.full_reveal_layer
	if(tilemap == null):
		print("No Tilemap Assigned to player! Movement will not work.")
	
	# Emit this signal once at the start of the game to make sure the Fog updates immediately
	#on_player_turn_ended.emit(tilemap.local_to_map(global_position)) 
	adjust_courage(3.0)
	tiles_visited.append(get_current_tile())
	print("Player started on Tile (%d,%d)"%[get_current_tile().x, get_current_tile().y])
	anim_return_to_idle.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if(gm.can_player_act == false):
		#return
	if(is_dead):
		anim_died.emit()
		return
	
	if(Input.is_action_just_pressed("debug_activate")):
		on_blackout()
		
		
	if(!lost_combat):
		if(Input.is_action_pressed("move_up")):
			anim_direction = 0
			if(is_moving):return
			next_tile_check.target_position = Vector2(0, -TILE_SIZE)
			try_move(Vector2.UP)
		elif (Input.is_action_pressed("move_down")):
			anim_direction = 1
			if(is_moving):return
			next_tile_check.target_position = Vector2(0, TILE_SIZE)
			try_move(Vector2.DOWN)
		elif(Input.is_action_pressed("move_left")):
			anim_direction = 2
			if(is_moving):return
			next_tile_check.target_position = Vector2(-TILE_SIZE,0)
			try_move(Vector2.LEFT)
		elif(Input.is_action_pressed("move_right")):
			anim_direction = 3
			if(is_moving):return
			next_tile_check.target_position = Vector2(TILE_SIZE,0)
			try_move(Vector2.RIGHT)
	else:
		if(Input.is_action_just_released("move_up") ||Input.is_action_just_released("move_down") ||
		Input.is_action_just_released("move_left") ||Input.is_action_just_released("move_right")):
			lost_combat = false

func _physics_process(delta: float) -> void:
	if(is_moving == false):
		return
		
	if(global_position == player_anim_sprite.global_position):
		is_moving = false
		if(!tiles_visited.has(get_current_tile())):
			tiles_visited.append(get_current_tile())
			print("Player has visited Tile (%d,%d)"%[get_current_tile().x, get_current_tile().y])
		## This will cause the game manager to run all end-of-turn behaviours
		# HERE we can resolve stuff like picking up items, activating traps, etc etc
		on_player_turn_ended.emit(tilemap.local_to_map(global_position)) 
		## After movement to a tile is finished, return to the idle animation if no more inputs are being done
		if(!Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_up") && 
		!Input.is_action_pressed("move_down") && !Input.is_action_pressed("move_right")):
			anim_return_to_idle.emit()
		
		return
	
	## Player Sprite Movement
	player_anim_sprite.global_position = player_anim_sprite.global_position.move_toward(global_position, movement_speed)
	
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
			var target_enemy = next_tile_check.get_collider() as Enemy
			resolve_combat(target_enemy, current_tile, target_tile)
			return # Whether or not we move is determined by the combat function. Break out of try_move.
		elif(next_tile_check.get_collider() is CourageBoost):
			var target_pickup = next_tile_check.get_collider() as CourageBoost
			target_pickup.on_pickup(self)
		elif(next_tile_check.get_collider() is Totem):
			var target_totem = next_tile_check.get_collider() as Totem
			target_totem.on_activate(self)
			gate.check_player_totem_count(self)
		elif(next_tile_check.get_collider() is ExitGate):
			var g = next_tile_check.get_collider() as ExitGate
			if(g.is_open):
				print("You made it out good job.")
			else:
				anim_return_to_idle.emit()
				return
			## TODO Scene Transition!
		else: # The only other thing it could possible be colliding with is an obstacle
			anim_return_to_idle.emit()
			return
	
	
	## Extract data out of the target tile, to see if it is walkable or not
	var target_tile_data:TileData = tilemap.get_cell_tile_data(target_tile)
	# If unoccupied but not walkable (i.e. Obstacle spaces, don't move
	if(target_tile_data.get_custom_data("Walkable") == false):
		anim_return_to_idle.emit()
		return
	if(target_tile_data.get_custom_data("SafeZone") == true):
		on_return_to_village()
		anim_is_moving.emit(anim_direction)
		move_to_tile(current_tile, target_tile)
		return
		
	## Need to check if the next tile has previously been visited.
	## If it hasn't, then moving there will have a courage cost.
	##print("Player Movement: Target Tile is (%d,%d)"%[target_tile.x, target_tile.y])
	var is_next_tile_unvisited:bool = true
	if(tiles_visited.has(target_tile)):
		##print("Player Movement: Target Tile has been visited")
		is_next_tile_unvisited = false
	
	if(is_next_tile_unvisited):
		if(courage_remaining > 0):
			anim_is_moving.emit(anim_direction)
			move_to_tile(current_tile, target_tile)
			adjust_courage(-0.2)
		else: ## tile is unvisited and there's no courage left
			print("You aren't brave enough to continue")
			##TODO Play an animation here to show that he's too scared to go on
			anim_is_too_scared.emit()
			return
	else: # Next tile has already been visited
		anim_is_moving.emit(anim_direction)
		move_to_tile(current_tile, target_tile)

func resolve_combat(target_enemy:Enemy, _current_tile:Vector2, _target_tile:Vector2) -> void:
	print("Player attacking %s"%target_enemy.name)
	
	var wisp_count = ceil(courage_remaining)
	
	if(wisp_count == 0 || courage_remaining < target_enemy.fear_level):
		print("Player is too scared to fight!")
		anim_is_too_scared.emit()
		lost_combat = true
	elif(wisp_count > target_enemy.fear_level):
		print("Player is very brave. Enemy killed without any courage loss")
		anim_attack.emit(anim_direction)
		target_enemy.on_death()
		move_to_tile(_current_tile, _target_tile)
		return
	elif(wisp_count == target_enemy.fear_level):
		print("Player is kinda brave. Enemy killed with courage loss")
		anim_attack.emit(anim_direction)
		target_enemy.on_death()
		move_to_tile(_current_tile, _target_tile)
		remove_wisps(1)
		return
	

func move_to_tile(current_tile:Vector2, target_tile:Vector2):
	is_moving = true
	# Move the player object forward, leaving the visual sprite behind to catch up a little bit
	# Hacky way to animate movement
	## check _physics_process for sprite movement details
	global_position = tilemap.map_to_local(target_tile)
	player_anim_sprite.global_position = tilemap.map_to_local(current_tile)

func adjust_courage(_delta:float) -> void:
	courage_remaining += _delta
	# Clamp to 5 (maximum number of wisps)
	if(courage_remaining > 5):
		courage_remaining = 5
	elif(recent_blackout && courage_remaining <= 0):
		on_die()
		
	wisp_manager.update_wisp_visuals()
	
func add_wisps(_delta:int) -> void:
	var num_current_wisps = ceil(courage_remaining)
	var target_num_wisps = num_current_wisps  + _delta
	
	if(target_num_wisps > 5):
		target_num_wisps = 5
	var courage_to_add = target_num_wisps - courage_remaining
	courage_remaining += courage_to_add
	wisp_manager.update_wisp_visuals()

func remove_wisps(_delta:int) -> void:
	var num_current_wisps = ceil(courage_remaining)
	var target_num_wisps = num_current_wisps - _delta
	if(target_num_wisps < 0):
		courage_remaining = 0
		return
	
	var courage_to_remove = courage_remaining - target_num_wisps
	courage_remaining -= courage_to_remove
	wisp_manager.update_wisp_visuals()



func get_current_tile() -> Vector2i:
	return tilemap.local_to_map(global_position)
	
	
func on_get_attacked(_fear_level:int):
	var player_wisp_count = ceil(courage_remaining)
	if(player_wisp_count == 0):
		on_die()
		return
	elif(player_wisp_count > _fear_level):
		## Player takes no damage and does not black out.
		## TODO need some way of conveying the fact that the attack didnt work?
		print("Player has high courage, this attack didn't affect them")
		return
	elif (player_wisp_count == _fear_level):
		## player loses the remainder of their smallest 1 Wisp, but does not black out.
		## Effectively truncates the decimal off the courage remaining stat.
		print("Player has equal courage. Losing 1 Wisp and not blacking out.")
		remove_wisps(1)
		return
	elif(player_wisp_count < _fear_level):
		## Player loses 1 Courage AND blacks out.
		print("Player is scared. Losing 1 Wisp and blacking out.")
		remove_wisps(1)
		on_blackout()
		return

func on_blackout() -> void:
	print("Player blacked out!")
	map_manager.reset_fog_completely()
	recent_blackout = true
	
func on_die() -> void:
	is_dead = true
	print("Player died!")
	# Play and wait for Death Animation if we have one
	## Stall here if the animation is still playing
	## To make sure the player sees the whole death animation
	await(player_anim_sprite.animation_finished)
	
	## PLAYER RESET
	# remove all visited tiles fromm the player's list
	tiles_visited.clear()
	# respawn player inside village
	global_position = tilemap.map_to_local(RESPAWN_TILE)
	# Reset courage back to 3
	courage_remaining = 3
	wisp_manager.update_wisp_visuals()
	
	## MAP RESET:
	#2: re-fog entire map
	map_manager.reset_fog_completely()
	#3: Respawn/Reactivate items
	if(pickup_respawner != null):
		pickup_respawner.mass_respawn()
	
	## RECOVER SAVED TILES
	#add tiles_recorded to tiles_visited.
	tiles_visited.append_array(tiles_recorded)
	#6: remove fog around tiles visited
	for t in tiles_visited:
		map_manager.update_fog(t)
	anim_return_to_idle.emit()
	courage_remaining = 3
	wisp_manager.update_wisp_visuals()
	is_dead = false

func on_return_to_village() -> void:
	print("Player returned to village!")
	if(recent_blackout == true):
		recent_blackout = false
		# Re-add previously discovered tiles to the tiles visited array
		for t in tiles_recorded:
			map_manager.update_fog(t)
			if(!tiles_visited.has(t)):
				tiles_visited.append(t)
		# Re-remove the fog from around those tiles.
		
	if(courage_remaining < 3):
		courage_remaining = 3.0
		wisp_manager.update_wisp_visuals()
	
	for t in tiles_visited:
		if(!tiles_recorded.has(t)):
			tiles_recorded.append(t)

func on_map_fog_reset() -> void:
	tiles_visited.clear()
	tiles_visited.append(get_current_tile())
	
