extends Enemy

# The hypnosnail drifts around the arena like the omenamato, but without the
# hopping: it glides smoothly, trying to keep a comfortable distance from the
# player (fleeing when crowded, closing in when the player drifts too far) and
# periodically lobs a hypnoball projectile at them.

# Movement: maintain a distance band around the player.
@export var move_speed_override: float = 90.0
# Stay roughly this far from the player. Closer than min -> flee; farther than
# max -> approach. Between the two it strafes/idles.
@export var preferred_min_distance: float = 220.0
@export var preferred_max_distance: float = 360.0
# How quickly velocity steers toward the desired direction.
@export var turn_rate: float = 3.0
@export var edge_margin: float = 80.0
# Sideways drift so it doesn't sit perfectly still inside the comfort band.
@export var strafe_speed: float = 40.0

# Shooting.
@export var fire_interval: float = 2.0
@export var fire_interval_jitter: float = 0.6
@onready var projectile_scene: PackedScene = preload("res://scenes/Enemies/projectiles/hypnoball.tscn")

@onready var drop_collectable: PackedScene = preload("res://scenes/collectables/speed_collectable.tscn")

var player: Node2D
var _fire_timer: float = 0.0
var _strafe_sign: float = 1.0


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	_reset_fire_timer()
	_strafe_sign = 1.0 if randf() < 0.5 else -1.0


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		velocity = velocity.lerp(Vector2.ZERO, turn_rate * delta)
		move_and_slide()
		return

	_update_movement(delta)
	_update_shooting(delta)


func _update_movement(delta: float) -> void:
	var to_player := player.global_position - global_position
	var distance := to_player.length()
	var away := Vector2.ZERO if distance < 0.001 else -to_player / distance

	var desired := Vector2.ZERO
	if distance < preferred_min_distance:
		# Too close: back away from the player.
		desired = away * move_speed_override
	elif distance > preferred_max_distance:
		# Too far: close the gap so it stays a threat.
		desired = -away * move_speed_override
	else:
		# In the comfort band: strafe perpendicular to the player so it keeps
		# circling rather than freezing in place.
		var perpendicular := Vector2(away.y, -away.x) * _strafe_sign
		desired = perpendicular * strafe_speed

	# Steer away from the screen edges so it doesn't pin itself in a corner.
	desired += _edge_avoidance() * move_speed_override

	velocity = velocity.lerp(desired, turn_rate * delta)
	move_and_slide()

	if absf(velocity.x) > 1.0:
		sprite.flip_h = velocity.x < 0.0


func _edge_avoidance() -> Vector2:
	var screen := get_viewport_rect().size
	var pos := global_position
	var push := Vector2.ZERO
	if pos.x < edge_margin:
		push.x += 1.0
	elif pos.x > screen.x - edge_margin:
		push.x -= 1.0
	if pos.y < edge_margin:
		push.y += 1.0
	elif pos.y > screen.y - edge_margin:
		push.y -= 1.0
	if push != Vector2.ZERO and randf() < 0.02:
		_strafe_sign = -_strafe_sign
	return push


func _update_shooting(delta: float) -> void:
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire()
		_reset_fire_timer()


func _fire() -> void:
	if projectile_scene == null or not is_instance_valid(player):
		return
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return
	var ball := projectile_scene.instantiate() as Node2D
	scene_root.add_child(ball)
	ball.global_position = global_position
	var direction := player.global_position - global_position
	if ball.has_method("launch"):
		ball.launch(direction)


func _reset_fire_timer() -> void:
	_fire_timer = fire_interval + randf_range(-fire_interval_jitter, fire_interval_jitter)


func die(multiplier: int = 1) -> void:
	_drop_collectable()
	super(multiplier)


func _drop_collectable() -> void:
	if drop_collectable == null:
		return
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return
	var instance := drop_collectable.instantiate() as Node2D
	scene_root.add_child(instance)
	instance.global_position = global_position
