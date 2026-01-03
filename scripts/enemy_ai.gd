extends AbstractController
class_name EnemyAI

@export 
var unit_manager: UnitManager

@export
var enemy_faction: Faction

func start_turn():
	super()
	for unit in enemy_faction.units:
		# Simple AI: Move to a random reachable cell
		var reachable_cells := unit_manager.get_potential_paths(unit)
		if reachable_cells.size() > 0:
			var target_cell = reachable_cells[randi() % reachable_cells.size()]
			await unit_manager.move_unit(unit, target_cell)

	end_turn()