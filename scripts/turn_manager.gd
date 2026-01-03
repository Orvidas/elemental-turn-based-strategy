extends Node2D
class_name TurnManager

var turn_order: Array[AbstractController] = []
var current_turn_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is AbstractController:
			turn_order.append(child)
			child.turn_ended.connect(change_turn)
	
	turn_order[current_turn_index].start_turn()
	print("Turn Manager ready. Starting turn for: %s" % turn_order[current_turn_index].name)

func change_turn() -> void:
	current_turn_index = (current_turn_index + 1) % turn_order.size()
	print("Starting turn for: %s" % turn_order[current_turn_index].name)
	turn_order[current_turn_index].start_turn()