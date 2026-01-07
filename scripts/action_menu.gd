extends Node2D
class_name ActionMenu

@export
var map: Map

@export
var unit_manager: UnitManager

@export
var cursor: Sprite2D

@export
var battle_manager: BattleManager

@onready
var action_menu = $ActionMenu

@onready
var attack_button = $ActionMenu/AttackBtn

@onready
var wait_button = $ActionMenu/WaitBtn

var selected_unit: Unit = null

var attackable_enemies: Array[Unit] = []

var select_target: Unit = null

signal menu_closed(is_canceled: bool)

signal highlight_targets(targets: Dictionary)

signal clear_highlights

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and visible:
		visible = false
		get_viewport().set_input_as_handled()
		emit_signal("menu_closed", true)
	elif event.is_action_pressed("cancel") and select_target != null:
		select_target = null
		cursor.position = selected_unit.position
		get_viewport().set_input_as_handled()
		visible = true
		emit_signal("clear_highlights")

	if event.is_action_pressed("select") and select_target != null:
		visible = false
		get_viewport().set_input_as_handled()
		await battle_manager.execute_battle(selected_unit, select_target)
		select_target = null
		attackable_enemies = []
		emit_signal("menu_closed", false)

	if event is InputEventMouseMotion and select_target != null:
		var mouse_pos = map.get_global_mouse_position()
		var cell = map.local_to_map(mouse_pos)
		var unit = unit_manager.get_unit(cell)
		if unit in attackable_enemies:
			cursor.position = map.map_to_local(cell)
			select_target = unit

func display_menu_for_unit(unit: Unit) -> void:
	selected_unit = unit
	position = unit.position

	attackable_enemies = unit_manager.get_enemies_in_range(unit)
	attack_button.visible = attackable_enemies.size() > 0
	
	wait_button.visible = true
	
	visible = true

func attack() -> void:
	var target_dict := {UnitManager.DANGER: []}
	for enemy in attackable_enemies:
		target_dict[UnitManager.DANGER].append(enemy.grid_position)
	emit_signal("highlight_targets", target_dict)

	visible = false
	select_target = attackable_enemies[0]
	cursor.position = select_target.position

func wait() -> void:
	selected_unit.wait()
	visible = false
	emit_signal("menu_closed", false)
