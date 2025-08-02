class_name Enemy
extends Area2D

@export var fear_level:int = 2

@export var player:Player

@export var map_manager:FogManager
@export var tilemap:TileMapLayer
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	if(player == null):
		print("Player not assigned to enemy %s"%name)
	player.on_player_turn_ended.connect(try_find_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!anim_sprite.is_playing()):
		anim_sprite.play("idle")

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
			player.on_get_attacked(fear_level)
			anim_sprite.play("Attack")
			# Round player courage up to get the number of wisps that they have. 
			
			return # Player has been located, don't need to search remaining neighbour tiles.

func get_current_tile() -> Vector2i:
	return tilemap.local_to_map(self.global_position)

func on_death() -> void:
	queue_free()
