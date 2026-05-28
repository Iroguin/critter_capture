extends CanvasLayer

@onready var high_scores_panel: PanelContainer = $Control/MarginContainer/Highscores_Panel
@onready var start_button: Button = $Control/MarginContainer/VBoxContainer/Start_Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	high_scores_panel.visible = false
	AudioHandler.play_music("res://assets/audio/crittercapture.mp3")
	start_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	AudioHandler.play_click()
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_quit_button_pressed() -> void:
	AudioHandler.play_click()
	await get_tree().create_timer(0.11).timeout
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	AudioHandler.play_click()
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")


func _on_high_scores_button_pressed() -> void:
	AudioHandler.play_click()
	high_scores_panel.visible = !high_scores_panel.visible


func _on_appearance_button_pressed() -> void:
	AudioHandler.play_click()
	get_tree().change_scene_to_file("res://scenes/character_select_menu.tscn")
