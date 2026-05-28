extends Node

const CONFIG_PATH := "user://config.cfg"
const AUDIO_BUSES: Array[String] = ["Master", "UI", "SFX", "Music"]
const DEFAULT_RESOLUTION := Vector2i(1920, 1080)
const DEFAULT_MOVEMENT_MODE := "WASD"
const DEFAULT_PLAYER_NAME := "Player"
const DEFAULT_TRAIL_COLOR := Color(0.48452926, 0.9063318, 1, 1)
const DEFAULT_HAT := ""
const DEFAULT_PLAYER_SPRITE := "res://assets/sprites/critters/player_test.png"

var _config := ConfigFile.new()


func _ready() -> void:
	_config.load(CONFIG_PATH)
	_apply_audio()
	_apply_video()


func _save() -> void:
	_config.save(CONFIG_PATH)


# audio

func get_volume(bus: String) -> float:
	return _config.get_value("audio", bus, 1.0)


func set_volume(bus: String, value: float) -> void:
	_config.set_value("audio", bus, value)
	var idx := AudioServer.get_bus_index(bus)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(value))
	_save()


func _apply_audio() -> void:
	for bus in AUDIO_BUSES:
		var idx := AudioServer.get_bus_index(bus)
		if idx >= 0:
			AudioServer.set_bus_volume_db(idx, linear_to_db(get_volume(bus)))


# video

func get_resolution() -> Vector2i:
	return _config.get_value("video", "resolution", DEFAULT_RESOLUTION)


func set_resolution(value: Vector2i) -> void:
	_config.set_value("video", "resolution", value)
	_save()
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(value)
		var center := DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
		DisplayServer.window_set_position(center - value / 2)


func get_fullscreen() -> bool:
	return _config.get_value("video", "fullscreen", false)


func set_fullscreen(value: bool) -> void:
	_config.set_value("video", "fullscreen", value)
	_save()
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		set_resolution(get_resolution())


func _apply_video() -> void:
	if get_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		var size := get_resolution()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(size)
		var center := DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
		DisplayServer.window_set_position(center - size / 2)


# gameplay

func get_movement_mode() -> String:
	return _config.get_value("gameplay", "movement_mode", DEFAULT_MOVEMENT_MODE)


func set_movement_mode(value: String) -> void:
	_config.set_value("gameplay", "movement_mode", value)
	_save()


func get_player_name() -> String:
	return _config.get_value("gameplay", "player_name", DEFAULT_PLAYER_NAME)


func set_player_name(value: String) -> void:
	_config.set_value("gameplay", "player_name", value)
	_save()


func get_trail_color() -> Color:
	return _config.get_value("gameplay", "trail_color", DEFAULT_TRAIL_COLOR)


func set_trail_color(value: Color) -> void:
	_config.set_value("gameplay", "trail_color", value)
	_save()


func get_hat() -> String:
	return _config.get_value("gameplay", "hat", DEFAULT_HAT)


func set_hat(value: String) -> void:
	_config.set_value("gameplay", "hat", value)
	_save()


func get_player_sprite() -> String:
	return _config.get_value("gameplay", "player_sprite", DEFAULT_PLAYER_SPRITE)


func set_player_sprite(value: String) -> void:
	_config.set_value("gameplay", "player_sprite", value)
	_save()


# highscores

func get_all_highscores() -> Array:
	return _config.get_value("highscores", "entries", []).duplicate(true)


func get_top_highscores(n: int = 10) -> Array:
	var all := get_all_highscores()
	all.sort_custom(func(a, b): return int(a.points) > int(b.points))
	return all.slice(0, n)


func add_highscore(player: String, points: int, time: float, color: Color = Color.WHITE) -> int:
	var entries := get_all_highscores()
	var date := int(Time.get_unix_time_from_system())
	entries.append({
		"name": player,
		"points": points,
		"time": time,
		"date": date,
		"color": color,
	})
	_config.set_value("highscores", "entries", entries)
	_save()
	return date


func format_highscore_entry(entry: Dictionary) -> String:
	var entry_time := float(entry.get("time", 0.0))
	var minutes := int(entry_time / 60)
	var seconds := int(entry_time) % 60
	var time_str := "%02d:%02d" % [minutes, seconds]
	var date_str := Time.get_date_string_from_unix_time(int(entry.get("date", 0)))
	return "%s — %d pts — %s — %s" % [
		entry.get("name", "?"),
		int(entry.get("points", 0)),
		time_str,
		date_str,
	]


func _format_highscore_line(rank: int, entry: Dictionary, highlight: bool) -> String:
	var inner := format_highscore_entry(entry)
	if highlight:
		return "%d. [color=yellow][b]%s[/b][/color]" % [rank, inner]
	var color: Color = entry.get("color", Color.WHITE)
	return "%d. [color=#%s]%s[/color]" % [rank, color.to_html(false), inner]


func get_formatted_highscores(top_n: int = 10, highlight_date: int = -1) -> String:
	var all := get_all_highscores()
	all.sort_custom(func(a, b): return int(a.points) > int(b.points))

	if highlight_date == -1:
		for e in all:
			var d := int(e.get("date", 0))
			if d > highlight_date:
				highlight_date = d

	var lines := PackedStringArray()
	var found_in_top := false
	var top := all.slice(0, top_n)
	for i in top.size():
		var entry: Dictionary = top[i]
		var is_highlight := int(entry.get("date", 0)) == highlight_date
		if is_highlight:
			found_in_top = true
		lines.append(_format_highscore_line(i + 1, entry, is_highlight))

	if not found_in_top and highlight_date != -1:
		for i in all.size():
			if int(all[i].get("date", 0)) == highlight_date:
				lines.append("...")
				lines.append(_format_highscore_line(i + 1, all[i], true))
				break

	return "\n".join(lines)
