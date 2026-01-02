extends GridContainer

@export
var map: Map

@export
var panel_stylebox: StyleBoxFlat

@export
var movement_color: Color = Color(0.373, 0.804, 0.894, 0.588)

@export
var movement_border_color: Color = Color(0.388, 0.608, 1.0, 0.784)

var panels: Array[Panel] = []

var highlighted_panels: Array[Panel] = []

var show_neutral_grid: bool = false

func _ready() -> void:
	columns = map.get_used_rect().size.x
	set_process_input(false)

	for i in range(map.get_used_rect().size.x * map.get_used_rect().size.y):
		var panel = Panel.new()
		panel.custom_minimum_size.x = map.tile_set.tile_size.x
		panel.custom_minimum_size.y = map.tile_set.tile_size.y
		panel.modulate.a = 1.0 if show_neutral_grid else 0.0
		panel.add_theme_stylebox_override("panel", panel_stylebox.duplicate())
		add_child(panel)
		panels.append(panel)

func highlight_selection(paths: Array[Vector2i]) -> void:
	print(paths)
	print(paths.size())
	for cell in paths:
		var index = cell.y * columns + cell.x
		if index >= 0 and index < panels.size():
			var panel = panels[index]
			panel.modulate.a = 1.0
			var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel")
			stylebox.draw_center = true
			stylebox.bg_color = movement_color
			stylebox.border_color = movement_border_color
			highlighted_panels.append(panel)

func clear_highlights() -> void:
	for panel in highlighted_panels:
		panel.modulate.a = 1.0 if show_neutral_grid else 0.0
		var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel")
		stylebox.draw_center = false
		stylebox.bg_color = Color.WHITE
		stylebox.border_color = Color.WHITE

	highlighted_panels.clear()

func toggle_neutral_grid() -> void:
	show_neutral_grid = not show_neutral_grid
	for panel in panels:
		if panel not in highlighted_panels:
			panel.modulate.a = 1.0 if show_neutral_grid else 0.0
