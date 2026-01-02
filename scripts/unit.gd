extends Sprite2D
class_name Unit

var grid_position: Vector2i = Vector2i.ZERO

@export
var move_speed := 200.0

func move(path: Array[Vector2i], map: Map) -> void:
	if path.is_empty():
		return

	for cell in path:
		var target_pos = map.map_to_local(cell)
		if position == target_pos:
			continue

		var dist = position.distance_to(target_pos)
		var duration = 0.0
		if move_speed > 0.0:
			duration = dist / move_speed
		else:
			duration = 0.1

		var tween = create_tween()
		tween.tween_property(self, "position", target_pos, duration)
		await tween.finished

	grid_position = path[-1]

func get_move_amount() -> int:
	return 5