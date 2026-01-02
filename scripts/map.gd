extends TileMapLayer
class_name Map

var top_level_tile_data: Dictionary = {}

func _ready() -> void:
	for cell in get_used_cells():
		var tile_data = get_cell_tile_data(cell)
		for child in get_children():
			if child is TileMapLayer and child.get_cell_tile_data(cell) != null:
				tile_data = child.get_cell_tile_data(cell)
		
		top_level_tile_data[cell] = tile_data

func get_top_level_tile_data(cell: Vector2i) -> TileData:
	return top_level_tile_data.get(cell, null)

func is_valid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < get_used_rect().size.x and cell.y < get_used_rect().size.y