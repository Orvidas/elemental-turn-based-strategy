extends Node2D
class_name ActionMenu

@export
var unit_manager: UnitManager

@export
var cursor: Sprite2D

@onready
var action_menu = $ActionMenu

@onready
var attack_button = $ActionMenu/AttackBtn

@onready
var wait_button = $ActionMenu/WaitBtn

var selected_unit: Unit = null

var attackable_enemies: Array[Unit] = []

signal menu_closed(is_canceled: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and visible:
		emit_signal("menu_closed", true)
		get_viewport().set_input_as_handled()
		visible = false

func display_menu_for_unit(unit: Unit) -> void:
	selected_unit = unit
	position = unit.position

	attackable_enemies = unit_manager.get_enemies_in_range(unit)
	attack_button.visible = attackable_enemies.size() > 0
	
	wait_button.visible = true
	
	visible = true

func attack() -> void:
	print("Attack action selected")
	visible = false
	emit_signal("menu_closed", false)

func wait() -> void:
	selected_unit.wait()
	visible = false
	emit_signal("menu_closed", false)