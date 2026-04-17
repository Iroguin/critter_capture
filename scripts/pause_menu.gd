extends CanvasLayer

signal movement_mode_changed(use_mouse: bool)
var game_paused := false
var is_mouse_mode := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

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
	get_tree().quit()


func _on_movement_toggle_button_pressed() -> void:
	is_mouse_mode = !is_mouse_mode
	if is_mouse_mode:
		$Control/VBoxContainer/Movement_Toggle_Button.text = "Movement: Mouse"
	else:
		$Control/VBoxContainer/Movement_Toggle_Button.text = "Movement: WASD"
	movement_mode_changed.emit(is_mouse_mode)
