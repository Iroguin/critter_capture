extends Enemy

@export var dash_speed: float = 700.0
@export var dash_duration: float = 0.2
@export var wind_up_time: float = 0.5
@export var rest_time: float = 0.6
@export var slide_deceleration: float = 700.0
@export var slide_min_speed: float = 30.0
@export var wet_trail_color: Color = Color(0.2, 0.3, 0.5, 0.4)
@export var wet_trail_width: float = 70.0
@export var wet_trail_fade_duration: float = 2.5
@export var wet_trail_sample_distance: float = 8.0

enum State { WIND_UP, DASH, SLIDE, REST }

@onready var splash_particles: CPUParticles2D = $Splash_Particles

var player: Node2D
var _state: int = State.WIND_UP
var _state_time: float = 0.0
var _dash_direction: Vector2 = Vector2.RIGHT
var _wet_trail: Line2D = null
var _last_trail_point: Vector2 = Vector2.ZERO


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	_enter_state(State.WIND_UP)


func _physics_process(delta: float) -> void:
	_state_time += delta

	match _state:
		State.WIND_UP:
			velocity = Vector2.ZERO
			if _state_time >= wind_up_time:
				_dash_direction = _direction_to_player()
				_enter_state(State.DASH)
		State.DASH:
			velocity = _dash_direction * dash_speed
			if _state_time >= dash_duration:
				_enter_state(State.SLIDE)
		State.SLIDE:
			velocity = velocity.move_toward(Vector2.ZERO, slide_deceleration * delta)
			_extend_wet_trail()
			if velocity.length() <= slide_min_speed:
				_enter_state(State.REST)
		State.REST:
			velocity = Vector2.ZERO
			if _state_time >= rest_time:
				_enter_state(State.WIND_UP)

	move_and_slide()

	if absf(velocity.x) > 1.0:
		sprite.flip_h = velocity.x > 0.0


func _enter_state(new_state: int) -> void:
	_state = new_state
	_state_time = 0.0
	if special_sprites.has("windup"):
		if new_state == State.WIND_UP:
			play_special("windup")
		else:
			return_to_idle()
	if splash_particles:
		splash_particles.emitting = (new_state == State.SLIDE)
	if new_state == State.SLIDE:
		_start_wet_trail()
	else:
		_end_wet_trail()


func _start_wet_trail() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return
	_wet_trail = Line2D.new()
	_wet_trail.width = wet_trail_width
	_wet_trail.default_color = wet_trail_color
	var gradient := Gradient.new()
	gradient.set_color(0, Color(wet_trail_color.r, wet_trail_color.g, wet_trail_color.b, 0.0))
	gradient.set_color(1, wet_trail_color)
	_wet_trail.gradient = gradient
	_wet_trail.joint_mode = Line2D.LINE_JOINT_ROUND
	_wet_trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_wet_trail.end_cap_mode = Line2D.LINE_CAP_ROUND
	_wet_trail.z_index = -1
	scene_root.add_child(_wet_trail)
	_wet_trail.add_point(global_position)
	_last_trail_point = global_position


func _extend_wet_trail() -> void:
	if _wet_trail == null:
		return
	if global_position.distance_to(_last_trail_point) >= wet_trail_sample_distance:
		_wet_trail.add_point(global_position)
		_last_trail_point = global_position


func _end_wet_trail() -> void:
	if _wet_trail == null:
		return
	var trail := _wet_trail
	_wet_trail = null
	var tween := trail.create_tween()
	tween.set_parallel(true)
	tween.tween_property(trail, "modulate:a", 0.0, wet_trail_fade_duration)
	tween.tween_method(
		func(t: float) -> void: _shrink_trail_back(trail, t),
		0.0, 1.0, wet_trail_fade_duration
	)
	tween.chain().tween_callback(trail.queue_free)


func _shrink_trail_back(trail: Line2D, t: float) -> void:
	if not is_instance_valid(trail) or trail.gradient == null:
		return
	trail.gradient.set_offset(0, t)


func die(multiplier: int = 1) -> void:
	_end_wet_trail()
	super(multiplier)


func _direction_to_player() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.from_angle(randf() * TAU)
	var to_player := player.global_position - global_position
	if to_player.length() < 0.001:
		return Vector2.from_angle(randf() * TAU)
	return to_player.normalized()
