extends TileMapLayer
class_name Map

func is_valid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < get_used_rect().size.x and cell.y < get_used_rect().size.y