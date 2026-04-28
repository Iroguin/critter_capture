extends CanvasLayer

const CLICK_SFX = "res://assets/audio/625271__gabriel_dornelles__menu-sfx-1.ogg"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_quit_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	await get_tree().create_timer(0.11).timeout
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")
