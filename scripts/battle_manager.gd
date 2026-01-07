extends Node2D
class_name BattleManager

@export
var map: Map

func get_forcast(attacker: Unit, defender: Unit) -> Dictionary:
    return {}

func execute_battle(attacker: Unit, defender: Unit) -> void:
    print("Executing battle between %s and %s" % [attacker.name, defender.name])
    await get_tree().create_timer(1).timeout