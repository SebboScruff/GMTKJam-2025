class_name MainMenuController
extends Control

@onready var home_page: Control = $HomePage
@onready var instruction_screen: Control = $"Instruction Screen"

func _ready() -> void:
	show_home_page()

func _on_play_button_pressed() -> void:
	load_game()


func _on_instr_button_pressed() -> void:
	show_instructions()


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("menu_go_back")):
		show_home_page()

func load_game() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/final_level.tscn")
	
func show_home_page() -> void:
	home_page.set_visible(true)
	home_page.set_process(true)
	
	instruction_screen.set_visible(false)
	instruction_screen.set_process(false)
	
func show_instructions() -> void:
	home_page.set_visible(false)
	home_page.set_process(false)
	
	instruction_screen.set_visible(true)
	instruction_screen.set_process(true)
