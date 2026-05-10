# controller_strategy.gd
extends MovementStrategy
class_name ControllerStrategy

const ACCELERATION := 1500.0
const DECELERATION := 1000.0
const DEADZONE := 0.2
const DEVICE := 0

var _velocity: Vector2 = Vector2.ZERO

func get_movement(actor: CharacterBody2D, speed) -> Vector2:
	var delta := actor.get_physics_process_delta_time()
	var raw := Vector2(
		Input.get_joy_axis(DEVICE, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(DEVICE, JOY_AXIS_LEFT_Y)
	)
	var magnitude := raw.length()
	var target := Vector2.ZERO
	if magnitude > DEADZONE:
		var scaled := minf((magnitude - DEADZONE) / (1.0 - DEADZONE), 1.0)
		target = raw.normalized() * scaled * speed

	if target == Vector2.ZERO:
		_velocity = _velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	else:
		_velocity = _velocity.move_toward(target, ACCELERATION * delta)
	return _velocity
