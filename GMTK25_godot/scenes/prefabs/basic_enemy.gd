class_name Enemy
extends Area2D

@export var courage_requirement:int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_death() -> void:
	print("Great Enemy Felled")
	queue_free()
