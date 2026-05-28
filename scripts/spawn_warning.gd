extends Node2D
class_name SpawnWarning


@export var lifetime: float = 1.0
@export var idle_fps: float = 4.0
@export var sway_degrees: float = 15.0
@export var frame1: Texture2D = preload("res://assets/sprites/misc/huutom1.png")
@export var frame2: Texture2D = preload("res://assets/sprites/misc/huutom2.png")

@onready var sprite: Sprite2D = $Sprite2D

var _frame_timer: float = 0.0
var _showing_first: bool = true


func _ready() -> void:
	sprite.texture = frame1
	sprite.rotation_degrees = sway_degrees
	# Self-destruct so main_game doesn't have to track us individually.
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _process(delta: float) -> void:
	if idle_fps <= 0.0:
		return
	_frame_timer += delta
	var frame_duration := 1.0 / idle_fps
	while _frame_timer >= frame_duration:
		_frame_timer -= frame_duration
		_showing_first = not _showing_first
		sprite.texture = frame1 if _showing_first else frame2
		sprite.rotation_degrees = -sprite.rotation_degrees
