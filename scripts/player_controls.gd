extends Node
class_name PlayerControls

@onready
var cursor = $Cursor

@export
var map: Map

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = map.get_global_mouse_position()
		var cell = map.local_to_map(mouse_pos)
		if map.is_valid(cell):
			cursor.position = map.map_to_local(cell)
