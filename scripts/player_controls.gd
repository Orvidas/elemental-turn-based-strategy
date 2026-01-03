extends AbstractController
class_name PlayerControls

@onready
var cursor = $Cursor

@export
var map: Map

@export
var unit_manager: UnitManager

@export
var player_faction: Faction

var selected_unit: Unit = null

var reachable_cells: Array[Vector2i] = []

var player_turn: bool = false

var active_units: Array[Unit] = []

signal unit_selected(paths: Array[Vector2i])

signal selection_canceled()

signal toggle_grid()

func _unhandled_input(event: InputEvent) -> void:
	
	# For inputs that can happen during either turn (i.e., pausing) 
	# place them above this check
	if not player_turn:
		return

	if event is InputEventMouseMotion:
		var mouse_pos = map.get_global_mouse_position()
		var cell = map.local_to_map(mouse_pos)
		if map.is_valid(cell):
			cursor.position = map.map_to_local(cell)

	if event.is_action_pressed("select"):
		var mouse_pos = map.get_global_mouse_position()
		var cell = map.local_to_map(mouse_pos)
		var unit = unit_manager.get_unit(cell)
		if unit != null and player_faction.units.has(unit) and active_units.has(unit):
			selected_unit = unit
			reachable_cells = unit_manager.get_potential_paths(unit)
			emit_signal("unit_selected", reachable_cells)
		elif selected_unit != null:
			if cell in reachable_cells:
				await unit_manager.move_unit(selected_unit, cell)
				active_units.erase(selected_unit)
			cancel_selection()

			if active_units.is_empty():
				end_turn()

	if event.is_action_pressed("cancel"):
		cancel_selection()

	if event.is_action_pressed("disable_grid"):
		emit_signal("toggle_grid")

func cancel_selection() -> void:
	selected_unit = null
	reachable_cells = []
	emit_signal("selection_canceled")

func start_turn():
	player_turn = true
	active_units = player_faction.units.duplicate()
	super()

func end_turn():
	player_turn = false
	cancel_selection()
	super()