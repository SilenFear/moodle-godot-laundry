extends SceneTree
const Puzzle = preload("res://puzzle.gd")
var checks := 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		push_error(message)
		quit(1)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var directions := {"U": Vector2i.UP, "D": Vector2i.DOWN, "L": Vector2i.LEFT, "R": Vector2i.RIGHT}
	var solutions = JSON.parse_string(FileAccess.get_file_as_string("res://tests/solutions.json"))
	var puzzle := Puzzle.new()
	for i in Puzzle.LEVELS.size():
		puzzle.load_level(i)
		check(not puzzle.solved(), "Level should start unsolved")
		for key in solutions[i]:
			check(puzzle.move(directions[key]) > 0, "Solution must work in real model")
		check(puzzle.solved(), "All baskets must reach goals")
	puzzle.load_level(0)
	puzzle.move(Vector2i.UP)
	check(puzzle.player == Vector2i(3, 3) and puzzle.boxes[0] == Vector2i(3, 2), "Push moves basket")
	puzzle.move(Vector2i.DOWN)
	check(puzzle.boxes[0] == Vector2i(3, 2), "Walking away must not pull basket")
	puzzle.move(Vector2i.LEFT)
	puzzle.move(Vector2i.LEFT)
	var old_pos := puzzle.player
	check(puzzle.move(Vector2i.LEFT) == 0 and puzzle.player == old_pos, "Wall blocks movement")
	puzzle.load_level(0)
	puzzle.move(Vector2i.UP)
	puzzle.move(Vector2i.UP)
	check(puzzle.move(Vector2i.UP) == 0, "Basket cannot be pushed through wall")
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.muted = true
	check(scene.screen == "home", "Game opens on home")
	scene.start_game()
	scene.remaining = 60
	scene.move(Vector2i.LEFT)
	scene.restart_level()
	check(scene.remaining == 60 and scene.level_moves == 1, "Reset cannot farm time or free moves")
	check(scene.puzzle.player == Vector2i(3, 4), "Reset restores board")
	scene.start_game()
	for i in solutions.size():
		for key in solutions[i]:
			scene.move(directions[key])
		check(scene.screen == "result", "Level reaches result")
		if i < solutions.size() - 1:
			scene.next_level()
	check(scene.total_score > 0 and scene.level == 2, "All three levels complete")
	scene.start_game()
	scene.remaining = 0.01
	scene._process(0.1)
	check(scene.screen == "result" and scene.remaining == 0, "Timeout shows failure result")
	scene.start_game()
	check(scene.total_score == 0 and scene.level == 0, "Replay resets progress")
	scene.show_home()
	check(scene.screen == "home", "Return home works")
	print("PASS: %d gameplay checks" % checks)
	await process_frame
	scene.queue_free()
	await process_frame
	quit()
