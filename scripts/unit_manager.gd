extends Node2D
class_name UnitManager

@export
var map: Map

var units: Dictionary = {}

var astargrid: AStarGrid2D = AStarGrid2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Faction:
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
	if not map.is_valid(target_cell):
		return false

	var original_grid_position = unit.grid_position
	var path := astargrid.get_id_path(unit.grid_position, target_cell)

	await unit.move(path, map)

	units.erase(original_grid_position)
	units[target_cell] = unit
	return true

func get_unit(cell: Vector2i) -> Unit:
	return units.get(cell, null)

func get_potential_paths(unit: Unit) -> Array[Vector2i]:
	if not units.has(unit.grid_position):
		return []

	var reachable_cells: Array[Vector2i] = []
	var move_path := {}
	move_path[unit.grid_position] = unit.get_move_amount()

	while not move_path.is_empty():
		var current_cell = move_path.keys()[0]
		var remaining_move = move_path[current_cell]
		move_path.erase(current_cell)

		var neighbors = [
			current_cell + Vector2i.RIGHT,
			current_cell + Vector2i.LEFT,
			current_cell + Vector2i.DOWN,
			current_cell + Vector2i.UP
		]

		for neighbor in neighbors:
			if map.is_valid(neighbor) and not astargrid.is_point_solid(neighbor) and remaining_move > 0:
				move_path[neighbor] = remaining_move - 1
				if neighbor not in reachable_cells:
					reachable_cells.append(neighbor)

	return reachable_cells
