extends Node

var time_elapsed: float = 0.0
var is_timer_running: bool = true
var total_points: int = 0
var alive: bool = true


func _ready() -> void:
	SignalHandler.enemy_captured.connect(_on_enemy_captured)


func _process(delta: float) -> void:
	if is_timer_running:
		time_elapsed += delta


func reset() -> void:
	time_elapsed = 0.0
	is_timer_running = true
	total_points = 0
	alive = true


func get_formatted_time() -> String:
	var minutes := int(time_elapsed / 60)
	var seconds := int(time_elapsed) % 60
	return "%02d:%02d" % [minutes, seconds]


func get_time() -> float:
	return time_elapsed


func start_death_sequence() -> void:
	if not alive:
		return
	alive = false
	is_timer_running = false


func end_game() -> void:
	SignalHandler.game_over.emit(total_points, time_elapsed)
	get_tree().paused = true


func _on_enemy_captured(points: int) -> void:
	if alive:
		total_points += points
