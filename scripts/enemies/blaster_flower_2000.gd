extends Enemy


@export var turn_rate: float = 0.8

var player: Node2D


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	velocity = _direction_toward_player() * move_speed


func _physics_process(delta: float) -> void:
	if _is_off_screen():
		velocity = _direction_toward_player() * move_speed
	else:
		var desired := _direction_toward_player() * move_speed
		velocity = velocity.lerp(desired, turn_rate * delta)

	move_and_slide()

	if absf(velocity.x) > 1.0:
		sprite.flip_h = velocity.x > 0.0


func _direction_toward_player() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.from_angle(randf() * TAU)
	var to_player := player.global_position - global_position
	if to_player.length() < 0.001:
		return Vector2.from_angle(randf() * TAU)
	return to_player.normalized()


func _is_off_screen() -> bool:
	var screen_rect := get_viewport_rect()
	var pos := global_position
	return pos.x < 0 or pos.x > screen_rect.size.x or pos.y < 0 or pos.y > screen_rect.size.y
