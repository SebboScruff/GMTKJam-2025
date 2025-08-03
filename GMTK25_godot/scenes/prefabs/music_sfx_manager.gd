class_name AudioManager
extends Node2D

@export var player:Player

@onready var bgm_source: AudioStreamPlayer2D = $"BGM-Source"
@onready var sfx_player_walk: AudioStreamPlayer2D = $SFX_PlayerWalk
@onready var sfx_player_attack: AudioStreamPlayer2D = $SFX_PlayerAttack
@onready var sfx_activate_totem: AudioStreamPlayer2D = $SFX_ActivateTotem
@onready var sfx_player_blackout: AudioStreamPlayer2D = $SFX_PlayerBlackout


func _ready() -> void:
	if(player == null):
		print("No Player assigned to Audio Manager")
	
	## Connect player audio signals
	player.audio_walk.connect(play_footsteps)
	player.audio_blackout_start.connect(play_blackout)
	player.audio_blackout_end.connect(pause_blackout)
	player.audio_attack.connect(play_attack)
	player.audio_totem_activate.connect(play_totem)
	
	## Start playing bgm
	bgm_source.play()
	
func play_footsteps() -> void:
	sfx_player_walk.play()
	
func play_attack() -> void:
	sfx_player_attack.play()
	
func play_totem() -> void:
	sfx_activate_totem.play()
	
func play_blackout() -> void:
	sfx_player_blackout.play()
	
func pause_blackout() -> void:
	sfx_player_blackout.stop()
