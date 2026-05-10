extends Enemy

@export var weave_frequency: float = 0.5 # bigger = more frequent
@export var weave_amplitude: float = 3.0

var player: Node2D
var _phase: float = 0.0


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	_phase = randf() * TAU


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	_phase += weave_frequency * TAU * delta

	var to_player := player.global_position - global_position
	if to_player.length() < 0.001:
		return
	var forward := to_player.normalized()
	var lateral := Vector2(-forward.y, forward.x)

	var direction := (forward + lateral * sin(_phase) * weave_amplitude).normalized()
	velocity = direction * move_speed
	move_and_slide()

	if absf(velocity.x) > 1.0:
		sprite.flip_h = velocity.x > 0.0
