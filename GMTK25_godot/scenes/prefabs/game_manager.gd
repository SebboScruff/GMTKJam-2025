class_name GameManager
extends Node

var can_player_act:bool
# Add array of enemy objects!

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func resolve_world() -> void:
	can_player_act = false
	
	# Cycle through all enemies and progress their behaviours one at a time
	
	can_player_act = true
