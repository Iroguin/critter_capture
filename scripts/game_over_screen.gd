extends CanvasLayer

@onready var time_label: Label = $Control/MarginContainer/HBoxContainer/Game_Over_Panel/MarginContainer/VBoxContainer/Time_Label
@onready var score_label: Label = $Control/MarginContainer/HBoxContainer/Game_Over_Panel/MarginContainer/VBoxContainer/Score_Label
@onready var line_edit: LineEdit = $Control/MarginContainer/HBoxContainer/Game_Over_Panel/MarginContainer/VBoxContainer/LineEdit
@onready var submit_button: Button = $Control/MarginContainer/HBoxContainer/Game_Over_Panel/MarginContainer/VBoxContainer/Submit_Button
@onready var restart_button: Button = $Control/MarginContainer/HBoxContainer/Game_Over_Panel/MarginContainer/VBoxContainer/Restart_Button
@onready var return_button: Button = $Control/MarginContainer/HBoxContainer/Game_Over_Panel/MarginContainer/VBoxContainer/Return_Button

@onready var highscores_panel: PanelContainer = $Control/MarginContainer/HBoxContainer/Highscores_Panel

var _pending_points: int = 0
var _pending_time: float = 0.0
var _committed: bool = false
var _last_highlight_date: int = -1
# Clear the name field the first time the user actually interacts with it.
# If they never touch it, the prefilled saved name is used on submit as before.
var _name_field_touched: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SignalHandler.game_over.connect(_on_game_over)
	line_edit.gui_input.connect(_on_line_edit_gui_input)
	self.visible = false
	return_button.visible = false
	restart_button.visible = false


func _on_game_over(points: int, time: float) -> void:
	_pending_points = points
	_pending_time = time
	_committed = false
	_name_field_touched = false
	score_label.text = "Score: " + str(points) + " pts"
	time_label.text = "Time: " + GameStateHandler.get_formatted_time()
	line_edit.text = GameConfig.get_player_name()
	highscores_panel.refresh()
	line_edit.editable = true
	submit_button.disabled = false
	self.visible = true
	line_edit.grab_focus()


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_commit_score()
	highscores_panel.refresh(_last_highlight_date)


func _on_line_edit_gui_input(event: InputEvent) -> void:
	if _name_field_touched:
		return
	var is_click: bool = event is InputEventMouseButton and event.pressed
	var is_type: bool = event is InputEventKey and event.pressed and event.unicode > 0
	if is_click or is_type:
		_name_field_touched = true
		line_edit.text = ""


func _on_submit_button_pressed() -> void:
	AudioHandler.play_click()
	_commit_score()
	highscores_panel.refresh(_last_highlight_date)


func _commit_score() -> void:
	if _committed:
		return
	_committed = true
	var entered_name := line_edit.text.strip_edges()
	if entered_name.is_empty():
		entered_name = GameConfig.get_player_name()
	GameConfig.set_player_name(entered_name)
	_last_highlight_date = GameConfig.add_highscore(entered_name, _pending_points, _pending_time, _get_trail_color())
	line_edit.editable = false
	submit_button.disabled = true
	return_button.visible = true
	restart_button.visible = true
	restart_button.grab_focus()


func _get_trail_color() -> Color:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p == null:
		return Color.WHITE
	var t := p.get_node_or_null("PlayerTrail") as Line2D
	if t == null:
		return Color.WHITE
	return t.default_color


func _on_return_button_pressed() -> void:
	AudioHandler.play_click()
	get_tree().paused = false
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_restart_button_pressed() -> void:
	AudioHandler.play_click()
	get_tree().paused = false
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
