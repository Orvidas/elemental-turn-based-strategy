extends Node
class_name AbstractController

signal turn_started
signal turn_ended

func start_turn() -> void:
	emit_signal("turn_started")

func end_turn() -> void:
	emit_signal("turn_ended")