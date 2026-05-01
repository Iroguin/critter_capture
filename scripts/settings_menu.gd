extends CanvasLayer

const CLICK_SFX = "res://assets/audio/625271__gabriel_dornelles__menu-sfx-1.ogg"

const RESOLUTIONS = {
	"1920 x 1080": Vector2i(1920, 1080),
	"1600 x 900": Vector2i(1600, 900),
	"1280 x 720": Vector2i(1280, 720),
	"1152 x 648": Vector2i(1152, 648),
	"2560 x 1664": Vector2i(2560, 1664),
}

@onready var resolution_options: OptionButton = $Control/MarginContainer/HBoxContainer/Video_Controls/Master_Volume_Panel/MarginContainer/VBoxContainer3/Resoltion_Options


func _ready() -> void:
	resolution_options.clear()
	var saved_size := GameConfig.get_resolution()
	var current_index := 0
	var i := 0
	for res_string in RESOLUTIONS:
		resolution_options.add_item(res_string)
		if RESOLUTIONS[res_string] == saved_size:
			current_index = i
		i += 1
	resolution_options.select(current_index)
	resolution_options.disabled = GameConfig.get_fullscreen()
	resolution_options.item_selected.connect(_on_resolution_selected)


func _on_resolution_selected(index: int) -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	GameConfig.set_resolution(RESOLUTIONS[resolution_options.get_item_text(index)])


func _on_return_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	await get_tree().create_timer(0.11).timeout
	get_tree().quit()


func _on_fullscreen_button_pressed() -> void:
	AuidioHandler.play_sfx(CLICK_SFX, "UI")
	GameConfig.set_fullscreen(not GameConfig.get_fullscreen())
	resolution_options.disabled = GameConfig.get_fullscreen()
