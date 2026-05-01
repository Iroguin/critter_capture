extends CanvasLayer

const CLICK_SFX = "res://assets/audio/625271__gabriel_dornelles__menu-sfx-1.ogg"

signal movement_mode_changed(mode: String)
var game_paused := false
var _movement_modes: Array[String] = ["WASD", "Mouse", "Free Move"]
var _mode_index := 0

@onready var movement_button := $Control/VBoxContainer/Movement_Toggle_Button
@onready var color_button := $Control/VBoxContainer/Color_Button
@onready var color_picker := $Control/VBoxContainer/Color_Button/ColorPicker
@onready var quit_button := $Control/VBoxContainer/Quit_Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	color_picker.visible = false
	var saved_mode := GameConfig.get_movement_mode()
	_mode_index = maxi(_movement_modes.find(saved_mode), 0)
	movement_button.text = "Movement: " + _movement_modes[_mode_index]
	movement_mode_changed.emit(_movement_modes[_mode_index])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			toggle_pause_menu()


func toggle_pause_menu():
	game_paused = !game_paused
	self.visible = game_paused
	get_tree().paused = game_paused


func _on_quit_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	await get_tree().create_timer(0.11).timeout
	get_tree().quit()


func _on_movement_toggle_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	_mode_index = (_mode_index + 1) % _movement_modes.size()
	var mode := _movement_modes[_mode_index]
	movement_button.text = "Movement: " + mode
	GameConfig.set_movement_mode(mode)
	movement_mode_changed.emit(mode)


func _on_color_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	color_picker.visible = !color_picker.visible


func _on_color_picker_color_changed(color: Color) -> void:
	SignalHandler.trail_color_changed.emit(color)


func _on_return_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	await get_tree().create_timer(0.11).timeout
	toggle_pause_menu()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_background_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	SignalHandler.background_changed.emit()
