class_name FogMap
extends TileMapLayer

var tile_alpha_values:Dictionary = {}

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.modulate.a = tile_alpha_values.get(coords, 1.0)
	
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return tile_alpha_values.has(coords)
	
func reset_opacities() -> void:
	for k in tile_alpha_values.keys():
		tile_alpha_values[k] = 1.0
	notify_runtime_tile_data_update()
	#tile_alpha_values.clear()
