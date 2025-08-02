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

func _on_player_anim_return_to_idle() -> void:
	play("idle")

func _on_player_anim_attack(dir: int) -> void:
	match(dir):
		0: ## Up
			play("atk_up")
		1: ## Down
			play("atk_down")
		2: ## Left
			play("atk_left")
		3: ## Right
			play("atk_right")
		_:
			print("Invalid movement direction passed to player sprite.")


func _on_player_anim_died() -> void:
	play("die")


func _on_player_anim_is_too_scared() -> void:
	play("too_scared")
