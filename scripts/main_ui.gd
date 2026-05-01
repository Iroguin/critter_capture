extends CanvasLayer

@onready var highscore_label := $Control/MarginContainer/highscore_label
@onready var time_label := $Control/MarginContainer/Time_Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHandler.enemy_captured.connect(_on_enemy_captured)

func _physics_process(delta: float) -> void:
	time_label.text = GameStateHandler.get_formatted_time()

func _on_enemy_captured(_points: int) -> void:
	highscore_label.text = str(GameStateHandler.total_points)
