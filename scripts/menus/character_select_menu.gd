extends CanvasLayer

const HATS: Array[String] = [
	"",
	"res://assets/sprites/outfits/top_hat.png",
	"res://assets/sprites/outfits/cat_ears.png",
	"res://assets/sprites/outfits/halo.png",
	"res://assets/sprites/outfits/silver_crown.png",
]

# Default first so the rotation order starts on player_test.
const PLAYER_SPRITES: Array[String] = [
	"res://assets/sprites/critters/player_test.png",
	"res://assets/sprites/critters/player_alt.png",
	"res://assets/sprites/critters/player_bw.png",
]

@onready var trail_example: Line2D = $Control/MarginContainer/VBoxContainer/HBoxContainer/Character_view/SubViewport/Trail_Example
@onready var color_picker: CustomColorPicker = $Control/MarginContainer/VBoxContainer/PanelContainer/ColorPicker
@onready var main_character = $Control/MarginContainer/VBoxContainer/HBoxContainer/Character_view/SubViewport/Main_Character
@onready var outfit_left_button: Button = $Control/MarginContainer/VBoxContainer/HBoxContainer/Outfit_Left_Button

var _original_color: Color
var _original_hat: String
var _original_player_sprite: String
var _hat_index: int = 0
var _player_sprite_index: int = 0


func _ready() -> void:
	_original_color = GameConfig.get_trail_color()
	_original_hat = GameConfig.get_hat()
	_original_player_sprite = GameConfig.get_player_sprite()
	_hat_index = maxi(0, HATS.find(_original_hat))
	_player_sprite_index = maxi(0, PLAYER_SPRITES.find(_original_player_sprite))

	trail_example.default_color = _original_color
	color_picker.color = _original_color
	color_picker.color_changed.connect(_on_color_picker_color_changed)
	main_character.process_mode = Node.PROCESS_MODE_DISABLED
	outfit_left_button.grab_focus()


func _on_color_picker_color_changed(color: Color) -> void:
	trail_example.default_color = color
	GameConfig.set_trail_color(color)
	SignalHandler.trail_color_changed.emit(color)


func _reset_outfit_and_color() -> void:
	color_picker.color = _original_color
	trail_example.default_color = _original_color
	GameConfig.set_trail_color(_original_color)
	SignalHandler.trail_color_changed.emit(_original_color)

	_hat_index = maxi(0, HATS.find(_original_hat))
	_apply_hat_to_preview()
	GameConfig.set_hat(_original_hat)

	_player_sprite_index = maxi(0, PLAYER_SPRITES.find(_original_player_sprite))
	_apply_player_sprite_to_preview()
	GameConfig.set_player_sprite(_original_player_sprite)


func _apply_hat_to_preview() -> void:
	if main_character and main_character.has_method("apply_hat"):
		main_character.apply_hat(HATS[_hat_index])


func _apply_player_sprite_to_preview() -> void:
	if main_character and main_character.has_method("apply_player_sprite"):
		main_character.apply_player_sprite(PLAYER_SPRITES[_player_sprite_index])


func _on_outfit_left_button_pressed() -> void:
	AudioHandler.play_click()
	_hat_index = (_hat_index - 1 + HATS.size()) % HATS.size()
	_apply_hat_to_preview()


func _on_outfit_right_button_pressed() -> void:
	AudioHandler.play_click()
	_hat_index = (_hat_index + 1) % HATS.size()
	_apply_hat_to_preview()


func _on_cancle_button_pressed() -> void:
	_reset_outfit_and_color()
	AudioHandler.play_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_confirm_button_pressed() -> void:
	GameConfig.set_hat(HATS[_hat_index])
	GameConfig.set_player_sprite(PLAYER_SPRITES[_player_sprite_index])
	AudioHandler.play_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_reset_button_pressed() -> void:
	_reset_outfit_and_color()
	AudioHandler.play_click()


func _on_player_switch_button_pressed() -> void:
	AudioHandler.play_click()
	_player_sprite_index = (_player_sprite_index + 1) % PLAYER_SPRITES.size()
	_apply_player_sprite_to_preview()
