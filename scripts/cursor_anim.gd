extends Sprite2D

@export
var default_unit_position: Unit

@export
var ANIMATION_SPEED := 0.65

@export
var SMALL_SCALE := Vector2(0.75, 0.75)

const LARGE_SCALE := Vector2(1.0, 1.0)

var time_passed := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var default_position := Vector2(8.0, 8.0) if default_unit_position == null else default_unit_position.position
	position = default_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta

	if time_passed >= ANIMATION_SPEED:
		time_passed = 0.0
		scale = SMALL_SCALE if scale == LARGE_SCALE else LARGE_SCALE