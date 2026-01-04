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

@export
var initial_hold_threshold := .55

@export
var fast_hold_threshold := .065

var hold_timer := 0.0

var hold_threshold := initial_hold_threshold

var selected_unit: Unit = null

var reachable_cells: Array[Vector2i] = []

var player_turn: bool = false

var active_units: Array[Unit] = []

var prev_cursor_grid_position: Vector2i = Vector2i.ZERO

signal unit_selected(paths: Array[Vector2i])

signal selection_canceled()

signal toggle_grid()

func _process(delta: float) -> void:

	# For inputs that can happen during either turn (e.g., pausing) 
	# place them above this check
	if not player_turn:
		return
	
	var input_dir := Input.get_vector("left", "right", "up", "down")	
	if input_dir == Vector2.ZERO:
		hold_timer = 0.0
		hold_threshold = initial_hold_threshold
	else:
		if hold_timer >= hold_threshold:
			hold_timer = 0.0
			hold_threshold = fast_hold_threshold

		if hold_timer == 0.0:
			var cell = map.local_to_map(cursor.position)
			if input_dir.x > 0:
				cell.x += 1
			elif input_dir.x < 0:
				cell.x -= 1

			if input_dir.y > 0:
				cell.y += 1
			elif input_dir.y < 0:
				cell.y -= 1

			if map.is_valid(cell):
				cursor.position = map.map_to_local(cell)	
		
		hold_timer += delta

	var cursor_grid_position := map.local_to_map(cursor.position)
	if prev_cursor_grid_position != cursor_grid_position:
		prev_cursor_grid_position = cursor_grid_position
		if selected_unit != null:
			return
		var unit = unit_manager.get_unit(cursor_grid_position)
		if unit != null:
			reachable_cells = unit_manager.get_potential_paths(unit)
			emit_signal("unit_selected", reachable_cells)
		else:
			emit_signal("selection_canceled")

func _unhandled_input(event: InputEvent) -> void:
	
	# For inputs that can happen during either turn (e.g., pausing) 
	# place them above this check
	if not player_turn:
		return

	if event is InputEventMouseMotion:
		var mouse_pos = map.get_global_mouse_position()
		var cell = map.local_to_map(mouse_pos)
		if map.is_valid(cell):
			cursor.position = map.map_to_local(cell)

	if event.is_action_pressed("select"):
		var cell = map.local_to_map(cursor.position)
		if selected_unit == null:
			var unit = unit_manager.get_unit(cell)
			if unit != null and player_faction.units.has(unit) and active_units.has(unit):
				selected_unit = unit
				reachable_cells = unit_manager.get_potential_paths(unit)
				emit_signal("unit_selected", reachable_cells)
		else:
			if cell in reachable_cells and unit_manager.get_unit(cell) == null:
				var moving_unit = selected_unit
				active_units.erase(selected_unit)
				cancel_selection()
				player_turn = false
				await unit_manager.move_unit(moving_unit, cell)
				player_turn = true

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

func start_turn() -> void:
	player_turn = true
	active_units = player_faction.units.duplicate()
	super()

func end_turn() -> void:
	player_turn = false
	cancel_selection()
	super()