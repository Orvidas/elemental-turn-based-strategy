extends Node2D
class_name UnitManager

enum {MOVE, DANGER}

@export
var map: Map

var units: Dictionary = {}

var factions: Array[Faction] = []

var astargrid: AStarGrid2D = AStarGrid2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Faction:
			factions.append(child)
			for unit in child.units:
				unit.grid_position = map.local_to_map(unit.position)
				units[unit.grid_position] = unit

	astargrid.region = map.get_used_rect()
	astargrid.cell_size = map.tile_set.tile_size
	astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER

	astargrid.update()
	
	for cell in map.get_used_cells():
		var is_solid = map.get_top_level_tile_data(cell).terrain_set == 0
		astargrid.set_point_solid(cell, is_solid)

func move_unit(unit: Unit, target_cell: Vector2i) -> bool:
	if not map.is_valid(target_cell) and not units.has(target_cell):
		return false

	var original_grid_position = unit.grid_position
	var path := astargrid.get_id_path(unit.grid_position, target_cell)

	await unit.move(path, map)

	units.erase(original_grid_position)
	units[target_cell] = unit
	return true

func get_unit(cell: Vector2i) -> Unit:
	return units.get(cell, null)

func get_potential_paths(unit: Unit) -> Dictionary:
	if not units.has(unit.grid_position):
		return {}

	# Clear all units from the astargrid
	for clear_unit in units.values():
		astargrid.set_point_solid(clear_unit.grid_position, false)

	# Mark enemy units as solid
	var enemy_factions: Array[Faction] = factions.duplicate()
	for faction in factions:
		if faction.units.has(unit):
			enemy_factions.erase(faction)

			for allied in faction.allied_factions:
				enemy_factions.erase(allied)
			break

	for enemy_faction in enemy_factions:
		for enemy_unit in enemy_faction.units:
			astargrid.set_point_solid(enemy_unit.grid_position, true)

	var reachable_cells := {MOVE: [unit.grid_position], DANGER: []}
	var move_path := {unit.grid_position: Vector2i(unit.get_move_amount(), MOVE)}

	while not move_path.is_empty():
		var current_cell = move_path.keys()[0]
		var remaining_move: int = move_path[current_cell].x
		var move_type: int = move_path[current_cell].y
		move_path.erase(current_cell)

		var neighbors = [
			current_cell + Vector2i.RIGHT,
			current_cell + Vector2i.LEFT,
			current_cell + Vector2i.DOWN,
			current_cell + Vector2i.UP
		]

		for neighbor in neighbors:
			if not map.is_valid(neighbor):
				continue

			if move_type == MOVE:
				if not astargrid.is_point_solid(neighbor) and remaining_move > 0 and not reachable_cells[MOVE].has(neighbor):
					move_path[neighbor] = Vector2i(remaining_move - 1, MOVE)
					reachable_cells[MOVE].append(neighbor)
					reachable_cells[DANGER].erase(neighbor)
				elif not reachable_cells[MOVE].has(neighbor):
					move_path[neighbor] = Vector2i(unit.get_attack_range() - 1, DANGER)
					reachable_cells[DANGER].append(neighbor)
			elif remaining_move > 0 and not reachable_cells[MOVE].has(neighbor) and not move_path.has(neighbor):
				move_path[neighbor] = Vector2i(remaining_move - 1, DANGER)
				reachable_cells[DANGER].append(neighbor)


	return reachable_cells
