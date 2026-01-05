extends Node2D
class_name ActionMenu

@onready
var action_menu = $ActionMenu

var selected_unit: Unit = null

signal menu_closed(is_canceled: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if selected_unit == null:
		print("Error")

	var wait_button := Button.new()
	wait_button.text = "Wait"
	wait_button.pressed.connect(wait)

	action_menu.add_child(wait_button)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		emit_signal("menu_closed", true)
		get_viewport().set_input_as_handled()
		queue_free()

func wait() -> void:
	selected_unit.wait()
	emit_signal("menu_closed", false)
	queue_free()