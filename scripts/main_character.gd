extends CharacterBody2D

const SPEED = 400.0
const DEATH_ANIMATION_DURATION := 1.2

@export var health := 1.0
# coefficient 0 => no combo, 1 => combo times number of enemies cought
@export var multiplier_coefficient: float = 1.0

@onready var sprite := $PlayerTest
@onready var collision := $CollisionShape2D
@onready var trail :=  $PlayerTrail
@onready var particles_template := $PlayerTrailLoopParticles
@onready var combo_label := $Combo_Label
@onready var hat_sprite: Sprite2D = $Hat_Sprite

# the default movement is wasd MovementStrategy is a class
var current_strategy: MovementStrategy = WASDStrategy.new()

var _speed_multiplier: float = 1.0
var _boost_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	SignalHandler.loop_formed.connect(_on_loop_formed)
	GameStateHandler.reset()
	apply_hat(GameConfig.get_hat())
	apply_player_sprite(GameConfig.get_player_sprite())


func apply_hat(path: String) -> void:
	if path.is_empty():
		hat_sprite.visible = false
	else:
		hat_sprite.texture = load(path)
		hat_sprite.visible = true


func apply_player_sprite(path: String) -> void:
	if path.is_empty():
		return
	sprite.texture = load(path)

func _physics_process(delta: float) -> void:
	if not GameStateHandler.alive:
		velocity = Vector2.ZERO
		return

	if _boost_timer > 0.0:
		_boost_timer -= delta
		if _boost_timer <= 0.0:
			_speed_multiplier = 1.0

	# current strategy governs movement it can be found in "res://scripts/player_movement/"
	velocity = current_strategy.get_movement(self, SPEED * _speed_multiplier)
	move_and_slide()


func apply_speed_boost(multiplier: float, duration: float) -> void:
	_speed_multiplier = multiplier
	_boost_timer = duration

func take_damage(damage):
	health -= damage
	if health <= 0.0:
		die()
	print("remaining health: " + str(health))


func die():
	if not GameStateHandler.alive:
		return
	GameStateHandler.start_death_sequence()
	_explode()
	trail.explode()
	await get_tree().create_timer(DEATH_ANIMATION_DURATION).timeout
	GameStateHandler.end_game()


func _explode() -> void:
	sprite.visible = false
	collision.set_deferred("disabled", true)

	var burst := particles_template.duplicate() as CPUParticles2D
	burst.process_mode = Node.PROCESS_MODE_ALWAYS
	burst.amount = 80
	burst.scale_amount_max = 8.0
	burst.initial_velocity_min = 60.0
	burst.initial_velocity_max = 200.0
	get_tree().current_scene.add_child(burst)
	burst.global_position = global_position
	burst.emitting = true
	get_tree().create_timer(burst.lifetime + 0.5).timeout.connect(burst.queue_free)


func _on_loop_formed(caught_enemies: Array[Node]) -> void:
	var raw_multiplier := caught_enemies.size() * multiplier_coefficient
	var point_multiplier := int(raw_multiplier)
	if caught_enemies.size() > 1:
		if multiplier_coefficient != 0.0:
			_show_combo_popup(raw_multiplier)
	for node in caught_enemies:
		if node is Enemy:
			(node as Enemy).die(point_multiplier)


func _show_combo_popup(value: float) -> void:
	var scene_root := get_tree().current_scene
	var label := combo_label.duplicate() as Label
	if value == floorf(value):
		label.text = "x%d" % int(value)
	else:
		label.text = "x%.1f" % value
	label.add_theme_font_size_override("font_size", 96)
	label.modulate = Color.BLACK #trail.default_color
	label.global_position = global_position + Vector2(-30, -60)
	scene_root.add_child(label)

	var tween := label.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 80.0, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.chain().tween_callback(label.queue_free)


func _on_pause_menu_movement_mode_changed(mode: String) -> void:
	match mode:
		"Mouse": current_strategy = MouseStrategy.new()
		"Free Move": current_strategy = FreeMoveStrategy.new()
		_: current_strategy = WASDStrategy.new()
