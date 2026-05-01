extends CanvasLayer

const CLICK_SFX = "res://assets/audio/625271__gabriel_dornelles__menu-sfx-1.ogg"

@onready var line_edit: LineEdit = $Control/VBoxContainer/LineEdit
@onready var score_label: Label = $Control/VBoxContainer/Score_Label
@onready var time_label: Label = $Control/VBoxContainer/Time_Label
@onready var submit_button: Button = $Control/VBoxContainer/Submit_Button
@onready var highscores_label: Label = $Control/Highscores_Label
@onready var return_button: Button = $Control/VBoxContainer/Return_Button
@onready var restart_button: Button = $Control/VBoxContainer/Restart_Button

var _pending_points: int = 0
var _pending_time: float = 0.0
var _committed: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SignalHandler.game_over.connect(_on_game_over)
	self.visible = false
	return_button.visible = false
	restart_button.visible = false


func _on_game_over(points: int, time: float) -> void:
	_pending_points = points
	_pending_time = time
	_committed = false
	score_label.text = "Score: " + str(points)
	time_label.text = "Time: " + GameStateHandler.get_formatted_time()
	line_edit.text = GameConfig.get_player_name()
	highscores_label.text = str(GameConfig.get_formatted_highscores())
	line_edit.editable = true
	submit_button.disabled = false
	self.visible = true
	line_edit.grab_focus()


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_commit_score()
	highscores_label.text = str(GameConfig.get_formatted_highscores())


func _on_submit_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	_commit_score()
	highscores_label.text = str(GameConfig.get_formatted_highscores())


func _commit_score() -> void:
	if _committed:
		return
	_committed = true
	var entered_name := line_edit.text.strip_edges()
	if entered_name.is_empty():
		entered_name = GameConfig.get_player_name()
	GameConfig.set_player_name(entered_name)
	GameConfig.add_highscore(entered_name, _pending_points, _pending_time)
	line_edit.editable = false
	submit_button.disabled = true
	return_button.visible = true
	restart_button.visible = true


func _on_return_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	get_tree().paused = false
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_restart_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	get_tree().paused = false
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
