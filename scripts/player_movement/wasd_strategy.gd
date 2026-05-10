# wasd_strategy.gd
extends MovementStrategy
class_name WASDStrategy

const ACCELERATION := 1500.0
const DECELERATION := 1000.0

var _velocity: Vector2 = Vector2.ZERO

# WASD movement logic
func get_movement(actor: CharacterBody2D, speed) -> Vector2:
	var delta := actor.get_physics_process_delta_time()
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var target: Vector2 = input_dir * speed
	if input_dir == Vector2.ZERO:
		_velocity = _velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	else:
		_velocity = _velocity.move_toward(target, ACCELERATION * delta)
	return _velocity
