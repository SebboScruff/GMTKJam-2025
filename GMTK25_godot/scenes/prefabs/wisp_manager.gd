class_name WispManager
extends Node2D

const WISP_BASE_SIZE := 0.025

@onready var player: Player = $"../.."
var wisps = []

func _ready() -> void:
	wisps = get_children()

func update_wisp_visuals() -> void:
	if(player.courage_remaining == 0):
		for w in wisps:
			w.set_visible(false)
	# Convert the player's courage into a number of wisps
	var num_wisps = ceil(player.courage_remaining)
	## hide all wisps
	for w in wisps:
		w.set_visible(false)
	## show the relevant wisps
	for i in range(num_wisps):
		wisps[i].set_visible(true)
		wisps[i].scale = Vector2(WISP_BASE_SIZE,WISP_BASE_SIZE)
	## scale down the last wisp
	var last_wisp_size = player.courage_remaining - int(player.courage_remaining)
	if(last_wisp_size != 0):
		wisps[num_wisps-1].scale = Vector2(WISP_BASE_SIZE,WISP_BASE_SIZE)*(last_wisp_size)
