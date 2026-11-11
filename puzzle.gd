class_name LaundryPuzzle
extends RefCounted

const LEVELS = [
	["#######", "#     #", "#  .  #", "#  $  #", "#  @  #", "#     #", "#######"],
	["#######", "# . . #", "#  #  #", "# $ $ #", "#     #", "#  @  #", "#######"],
	["#######", "# ... #", "##   ##", "# $$$ #", "#     #", "#  @  #", "#######"]
]
const LIMITS = [90.0, 120.0, 150.0]
var walls: Array[Vector2i] = []
var goals: Array[Vector2i] = []
var boxes: Array[Vector2i] = []
var player := Vector2i.ZERO
var moves := 0
var pushes := 0

func load_level(index: int) -> void:
	walls.clear()
	goals.clear()
	boxes.clear()
	moves = 0
	pushes = 0
	var rows: Array = LEVELS[index]
	for y in rows.size():
		for x in rows[y].length():
			var cell := Vector2i(x, y)
			match rows[y][x]:
				"#": walls.append(cell)
				".": goals.append(cell)
				"$": boxes.append(cell)
				"@": player = cell

# 0 = blocked, 1 = walked, 2 = pushed. Boxes can only be pushed.
func move(direction: Vector2i) -> int:
	if absi(direction.x) + absi(direction.y) != 1:
		return 0
	var target := player + direction
	if target.x < 0 or target.x >= 7 or target.y < 0 or target.y >= 7 or target in walls:
		return 0
	var box_index := boxes.find(target)
	if box_index >= 0:
		var beyond := target + direction
		if beyond in walls or beyond in boxes or beyond.x < 0 or beyond.x >= 7 or beyond.y < 0 or beyond.y >= 7:
			return 0
		boxes[box_index] = beyond
		pushes += 1
	player = target
	moves += 1
	return 2 if box_index >= 0 else 1

func placed() -> int:
	var count := 0
	for box in boxes:
		if box in goals:
			count += 1
	return count

func solved() -> bool:
	return not boxes.is_empty() and placed() == boxes.size()
