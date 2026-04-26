extends CanvasLayer

@onready var highscore_label := $Control/MarginContainer/highscore_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHandler.enemy_captured.connect(_on_enemy_captured)


func _on_enemy_captured(points: int) -> void:
	highscore_label.text = str(highscore_label.text.to_int() + points)
