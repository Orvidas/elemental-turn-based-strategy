extends Node2D
class_name Faction

@export
var is_player_faction: bool = false

@export
var allied_factions: Array[Faction] = []

var units: Array[Unit] = []

func _ready() -> void:
	for child in get_children():
		if child is Unit:
			units.append(child)