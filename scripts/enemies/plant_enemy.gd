extends Enemy

@export var direction_spread_degrees: float = 30.0

func _ready() -> void:
	super()
	velocity = _direction_toward_screen() * move_speed

func _physics_process(_delta: float) -> void:
	if _is_off_screen():
		velocity = _direction_toward_screen() * move_speed
	move_and_slide()
	if absf(velocity.x) > 1.0:
		sprite.flip_h = velocity.x > 0.0

func _direction_toward_screen() -> Vector2:
	var center := get_viewport_rect().size * 0.5
	var to_center := (center - global_position)
	if to_center.length() < 0.001:
		return Vector2.from_angle(randf() * TAU)
	var spread := deg_to_rad(direction_spread_degrees)
	return to_center.normalized().rotated(randf_range(-spread, spread))

func _is_off_screen() -> bool:
	var screen_rect := get_viewport_rect()
	var pos := global_position
	return pos.x < 0 or pos.x > screen_rect.size.x or pos.y < 0 or pos.y > screen_rect.size.y
