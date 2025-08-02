extends AnimatedSprite2D

func _on_player_anim_is_moving(dir: int) -> void:
	match(dir):
		0: ## Up
			play("walk_up")
		1: ## Down
			play("walk_down")
		2: ## Left
			play("walk_left")
		3: ## Right
			play("walk_right")
		_:
			print("Invalid movement direction passed to player sprite.")
