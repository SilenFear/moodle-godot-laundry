extends Control
const Puzzle = preload("res://puzzle.gd")
const Board = preload("res://board.gd")
var puzzle := Puzzle.new()
var board: Control
var hud: Label
var hint: Label
var screen := "home"
var level := 0
var remaining := 0.0
var total_score := 0
var level_moves := 0
var sound := AudioStreamPlayer.new()
var sounds: Dictionary = {}
var muted := false
var sfx_button: Button

func _ready() -> void:
	theme = Theme.new()
	theme.default_font = preload("res://assets/NotoSansCJKtc-Regular.otf")
	add_child(sound)
	for kind in ["move", "push", "blocked", "win"]:
		sounds[kind] = load("res://assets/%s.wav" % kind)
	show_home()

func clear_screen() -> void:
	for child in get_children():
		if child != sound:
			remove_child(child)
			child.queue_free()

func text(value: String, y: float, font_size: int = 22, height: float = 50) -> Label:
	var label := Label.new()
	label.text = value
	label.position = Vector2(28, y)
	label.size = Vector2(484, height)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label

func button(value: String, rect: Rect2, action: Callable) -> Button:
	var control := Button.new()
	control.text = value
	control.position = rect.position
	control.size = rect.size
	control.add_theme_font_size_override("font_size", 21)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("28566a")
	style.set_corner_radius_all(12)
	control.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = Color("39778b")
	control.add_theme_stylebox_override("hover", hover)
	var pressed := style.duplicate()
	pressed.bg_color = Color("417c73")
	control.add_theme_stylebox_override("pressed", pressed)
	control.focus_mode = Control.FOCUS_NONE
	control.pressed.connect(action)
	add_child(control)
	return control

func footer() -> void:
	text("資通四勤 121271020 周柏睿", 816, 18, 32)
	text("字型：Noto Sans CJK TC（SIL OFL 1.1）\n圖形與音效：本作程式產生", 852, 13, 40)

func show_home() -> void:
	clear_screen()
	screen = "home"
	text("CAMPUS / LAUNDRY", 62, 18)
	text("宿舍洗衣日", 125, 44, 70)
	text("把洗衣籃，送到對的地方。", 204, 22)
	puzzle.load_level(0)
	var preview := Board.new()
	preview.puzzle = puzzle
	preview.position = Vector2(0, 275)
	preview.scale = Vector2(0.7, 0.7)
	preview.position.x = 81
	add_child(preview)
	text("方向鍵 / WASD 移動，手機點方向按鈕\n只能推、不能拉。洗衣籃全到洗衣機即可過關。\n三關限時挑戰；推入死角可重置本關。", 564, 18, 100)
	button("開始洗衣", Rect2(140, 690, 260, 64), start_game)
	footer()

func start_game() -> void:
	level = 0
	total_score = 0
	load_level()

func load_level() -> void:
	puzzle.load_level(level)
	remaining = Puzzle.LIMITS[level]
	level_moves = 0
	clear_screen()
	screen = "play"
	text("宿舍洗衣日  /  %d・%s" % [level + 1, ["先洗一籃", "尖峰時段", "洗衣間滿載"][level]], 18, 25)
	hud = text("", 76, 19, 70)
	hint = text("圓環是洗衣機，提籃是要推的洗衣籃", 148, 17, 36)
	board = Board.new()
	board.puzzle = puzzle
	board.position = Vector2(0, 196)
	add_child(board)
	button("↑", Rect2(226, 622, 88, 56), func(): move(Vector2i.UP))
	button("←", Rect2(130, 684, 88, 56), func(): move(Vector2i.LEFT))
	button("↓", Rect2(226, 684, 88, 56), func(): move(Vector2i.DOWN))
	button("→", Rect2(322, 684, 88, 56), func(): move(Vector2i.RIGHT))
	button("重置本關", Rect2(28, 762, 155, 44), restart_level)
	sfx_button = button("音效：關" if muted else "音效：開", Rect2(193, 762, 155, 44), toggle_sound)
	button("回首頁", Rect2(358, 762, 154, 44), show_home)
	footer()
	update_hud()

func toggle_sound() -> void:
	muted = not muted
	sfx_button.text = "音效：關" if muted else "音效：開"
	if muted:
		sound.stop()

func restart_level() -> void:
	# Restart restores the puzzle, but preserves remaining time and charged moves.
	puzzle.load_level(level)
	hint.text = "已重置位置；時間與累計步數不重置"
	board.queue_redraw()
	update_hud()

func _process(delta: float) -> void:
	if screen != "play":
		return
	remaining = maxf(remaining - delta, 0)
	update_hud()
	if remaining <= 0:
		show_result(false)

func update_hud() -> void:
	hud.text = "剩餘 %d 秒    步數 %d\n歸位 %d / %d    累計 %d 分" % [ceili(remaining), level_moves, puzzle.placed(), puzzle.boxes.size(), total_score]

func _unhandled_key_input(event: InputEvent) -> void:
	if screen != "play" or not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_UP, KEY_W: move(Vector2i.UP)
		KEY_DOWN, KEY_S: move(Vector2i.DOWN)
		KEY_LEFT, KEY_A: move(Vector2i.LEFT)
		KEY_RIGHT, KEY_D: move(Vector2i.RIGHT)
		KEY_R: restart_level()

func move(direction: Vector2i) -> void:
	if screen != "play":
		return
	var before := puzzle.placed()
	var result := puzzle.move(direction)
	board.blocked = result == 0
	board.flash = 0.16
	board.queue_redraw()
	if result == 0:
		hint.text = "這裡推不動！只能推，不能拉。"
		play_sound("blocked")
		return
	level_moves += 1
	hint.text = "洗衣籃歸位！" if puzzle.placed() > before else "推入死角時，按「重置本關」或 R"
	play_sound("push" if result == 2 else "move")
	update_hud()
	if puzzle.solved():
		total_score += maxi(100, 1000 + int(remaining) * 5 - level_moves * 10)
		play_sound("win")
		show_result(true)

func play_sound(kind: String) -> void:
	if not muted:
		sound.stream = sounds[kind]
		sound.play()

func show_result(won: bool) -> void:
	clear_screen()
	screen = "result"
	var finished := won and level == Puzzle.LEVELS.size() - 1
	text("LAUNDRY / RESULT", 110, 18)
	text("全部洗好了！" if finished else ("本關完成！" if won else "時間到了"), 195, 40, 72)
	text("累計成績  %d 分" % total_score, 315, 30)
	text("本關步數 %d · 剩餘 %d 秒\n計分：1000 + 剩餘秒數 × 5 − 步數 × 10\n每關至少 100 分，完成三關即獲勝。" % [level_moves, ceili(remaining)], 390, 18, 110)
	if won and not finished:
		button("下一關：更多洗衣籃", Rect2(95, 560, 350, 64), next_level)
	else:
		button("再玩一次", Rect2(140, 560, 260, 64), start_game)
	button("回首頁", Rect2(140, 650, 260, 56), show_home)
	footer()

func next_level() -> void:
	level += 1
	load_level()
