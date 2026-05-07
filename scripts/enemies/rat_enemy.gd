extends Enemy

const WANDER_RADIUS := 120.0
const WANDER_DRIFT := 60.0
const TURN_RATE := 2.5

var player: Node2D
var _wander_offset := Vector2.ZERO


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	_wander_offset = Vector2.from_angle(randf() * TAU) * randf() * WANDER_RADIUS



func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_wander_offset += Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * WANDER_DRIFT * delta
	_wander_offset = _wander_offset.limit_length(WANDER_RADIUS)

	var desired := (player.global_position + _wander_offset - global_position).normalized() * move_speed
	velocity = velocity.lerp(desired, TURN_RATE * delta)
	move_and_slide()

	if absf(velocity.x) > 1.0:
		sprite.flip_h = velocity.x > 0.0
