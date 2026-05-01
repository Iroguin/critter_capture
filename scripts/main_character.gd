extends CharacterBody2D

const SPEED = 400.0
const DEATH_ANIMATION_DURATION := 1.2

@export var health := 1.0

@onready var sprite := $PlayerTest
@onready var collision := $CollisionShape2D
@onready var trail :=  $PlayerTrail
@onready var particles_template := $PlayerTrailLoopParticles

# the default movement is wasd MovementStrategy is a class
var current_strategy: MovementStrategy = WASDStrategy.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	SignalHandler.loop_formed.connect(_on_loop_formed)
	GameStateHandler.reset()

func _physics_process(delta: float) -> void:
	if not GameStateHandler.alive:
		velocity = Vector2.ZERO
		return
	# current strategy governs movement it can be found in "res://scripts/player_movement/"
	velocity = current_strategy.get_movement(self, SPEED)
	move_and_slide()

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
	for node in caught_enemies:
		if node is Enemy:
			(node as Enemy).die()


func _on_pause_menu_movement_mode_changed(mode: String) -> void:
	match mode:
		"Mouse": current_strategy = MouseStrategy.new()
		"Free Move": current_strategy = FreeMoveStrategy.new()
		_: current_strategy = WASDStrategy.new()
