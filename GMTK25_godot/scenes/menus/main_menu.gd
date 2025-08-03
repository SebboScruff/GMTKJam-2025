class_name MainMenuController
extends Control

const LEVEL = preload("res://scenes/levels/final_level.tscn")

@onready var home_page: Control = $HomePage
@onready var instruction_screen: Control = $"Instruction Screen"

func _ready() -> void:
	## Connect up button signals here
	pass

func load_game() -> void:
	get_tree().change_scene_to_packed(LEVEL)
	
func show_home_page() -> void:
	home_page.set_visible(true)
	instruction_screen.set_visible(false)
	
func show_instructions() -> void:
	home_page.set_visible(false)
	instruction_screen.set_visible(true)
