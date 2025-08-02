class_name PickupRespawner
extends Node

func mass_respawn() -> void:
	for c in get_children():
		if(c is CourageBoost):
			c.reset()
