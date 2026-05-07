extends Node2D

const FALLBACK_ENEMY_SCENE: PackedScene = preload("res://scenes/Enemies/rat_enemy.tscn")
const SPAWN_INTERVAL := 1.5

@export var stages: Array[EnemyStage] = []

@onready var enemy_spawn_path: Path2D = $Enemy_Spawn_Path

var _spawn_timer: Timer
var current_bg = 4

func _ready() -> void:
	_rebuild_spawn_path()
	get_tree().root.size_changed.connect(_rebuild_spawn_path)

	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = _current_stage_interval()
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
	var stage := _current_stage()
	var scene := _pick_enemy_scene(stage)

	var spawn_point := PathFollow2D.new()
	spawn_point.loop = false
	enemy_spawn_path.add_child(spawn_point)
	spawn_point.progress_ratio = randf()

	var enemy := scene.instantiate()
	enemy.global_position = spawn_point.global_position
	add_child(enemy)
	spawn_point.queue_free()

	_spawn_timer.wait_time = _current_stage_interval(stage)


func _current_stage(t: float = -1.0) -> EnemyStage:
	if t < 0.0:
		t = GameStateHandler.get_time()
	var current: EnemyStage = null
	for stage in stages:
		if stage == null:
			continue
		if stage.time_threshold <= t:
			if current == null or stage.time_threshold > current.time_threshold:
				current = stage
	return current


func _current_stage_interval(stage: EnemyStage = null) -> float:
	if stage == null:
		stage = _current_stage()
	if stage != null and stage.spawn_interval > 0.0:
		return stage.spawn_interval
	return SPAWN_INTERVAL


func _pick_enemy_scene(stage: EnemyStage) -> PackedScene:
	if stage == null or stage.enemy_scenes.is_empty():
		return FALLBACK_ENEMY_SCENE
	var scenes := stage.enemy_scenes
	var weights := stage.enemy_weights
	if weights.size() != scenes.size():
		return scenes[randi() % scenes.size()]
	var total := 0.0
	for w in weights:
		total += w
	if total <= 0.0:
		return scenes[randi() % scenes.size()]
	var roll := randf() * total
	var acc := 0.0
	for i in scenes.size():
		acc += weights[i]
		if roll <= acc:
			return scenes[i]
	return scenes[scenes.size() - 1]

func _on_background_changed():
	current_bg = (current_bg + 1) % 5
	$Backgrounds/CritterBgEmpty.visible = (current_bg == 0)
	$Backgrounds/CritterBgDoodles.visible = (current_bg == 1)
	$Backgrounds/CritterBgFlowers.visible = (current_bg == 2)
	$Backgrounds/CritterBgStamps.visible = (current_bg == 3)
