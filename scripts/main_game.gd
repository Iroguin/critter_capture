extends Node2D

const ENEMY_SCENE: PackedScene = preload("res://scenes/Enemies/default_enemy.tscn")
const SPAWN_INTERVAL := 1.5

@onready var enemy_spawn_path: Path2D = $Enemy_Spawn_Path

var _spawn_timer: Timer
var current_bg = 4

func _ready() -> void:
	_rebuild_spawn_path()
	get_tree().root.size_changed.connect(_rebuild_spawn_path)

	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = SPAWN_INTERVAL
	_spawn_timer.timeout.connect(_spawn_enemy)
	add_child(_spawn_timer)
	_spawn_timer.start()
	SignalHandler.background_changed.connect(_on_background_changed)

# resizes the enmy spawn location, godot handles resolution changes so shouldnt need
func _rebuild_spawn_path() -> void:
	var size := get_viewport_rect().size
	var curve := Curve2D.new()
	curve.add_point(Vector2.ZERO)
	curve.add_point(Vector2(size.x, 0))
	curve.add_point(Vector2(size.x, size.y))
	curve.add_point(Vector2(0, size.y))
	curve.add_point(Vector2.ZERO)
	enemy_spawn_path.curve = curve


func _spawn_enemy() -> void:
	var spawn_point := PathFollow2D.new()
	spawn_point.loop = false
	enemy_spawn_path.add_child(spawn_point)
	spawn_point.progress_ratio = randf()

	var enemy := ENEMY_SCENE.instantiate()
	enemy.global_position = spawn_point.global_position
	add_child(enemy)
	spawn_point.queue_free()

func _on_background_changed():
	current_bg = (current_bg + 1) % 5
	
	$Backgrounds/CritterBgEmpty.visible = (current_bg == 0)
	$Backgrounds/CritterBgDoodles.visible = (current_bg == 1)
	$Backgrounds/CritterBgFlowers.visible = (current_bg == 2)
	$Backgrounds/CritterBgStamps.visible = (current_bg == 3)
	
