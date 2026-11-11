extends Control
var puzzle: LaundryPuzzle
var flash := 0.0
var blocked := false
const TILE := 58.0
const ORIGIN := Vector2(67, 6)

func _process(delta: float) -> void:
	if flash > 0:
		flash = maxf(0, flash - delta)
		queue_redraw()

func _draw() -> void:
	if puzzle == null:
		return
	for y in 7:
		for x in 7:
			var cell := Vector2i(x, y)
			var pos := ORIGIN + Vector2(cell) * TILE
			var rect := Rect2(pos + Vector2(2, 2), Vector2(TILE - 4, TILE - 4))
			if cell in puzzle.walls:
				draw_style_box(_style(Color("294252")), rect)
				draw_line(pos + Vector2(10, 28), pos + Vector2(48, 28), Color("385361"), 2)
			else:
				draw_style_box(_style(Color("142733")), rect)
				if cell in puzzle.goals:
					draw_circle(pos + Vector2(29, 29), 21, Color("3b8d8b"))
					draw_circle(pos + Vector2(29, 29), 14, Color("183e4b"))
					draw_arc(pos + Vector2(29, 29), 17, 0, TAU, 32, Color("a1e5d5"), 2)
	for box in puzzle.boxes:
		var pos := ORIGIN + Vector2(box) * TILE
		var color := Color("89d4b4") if box in puzzle.goals else Color("e9b367")
		draw_style_box(_style(color), Rect2(pos + Vector2(10, 12), Vector2(38, 36)))
		draw_arc(pos + Vector2(29, 16), 12, PI, TAU, 20, color, 4)
		for i in 3:
			draw_line(pos + Vector2(18 + i * 10, 25), pos + Vector2(18 + i * 10, 40), Color("735d44"), 2)
	var center := ORIGIN + Vector2(puzzle.player) * TILE + Vector2(29, 29)
	var color := Color("f28181") if blocked and flash > 0 else Color("c7eaff")
	draw_circle(center, 18 + flash * 5, color)
	draw_circle(center + Vector2(-6, -3), 2.5, Color("17364a"))
	draw_circle(center + Vector2(6, -3), 2.5, Color("17364a"))
	draw_line(center + Vector2(-5, 7), center + Vector2(5, 7), Color("17364a"), 2)

func _style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	return style
