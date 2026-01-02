extends Sprite2D
class_name Unit

var grid_position: Vector2i = Vector2i(14,11)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move(path: Array[Vector2i], map: Map) -> void:
	for cell in path:
		position = map.map_to_local(cell)
		print("Moving to cell: ", cell)
		print("World position: ", position)

	grid_position = map.local_to_map(position)

func get_move_amount() -> int:
	return 5