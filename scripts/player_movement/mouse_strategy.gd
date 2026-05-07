# mouse_strategy.gd
extends MovementStrategy
class_name MouseStrategy

var target_position: Vector2

# mouse movement logic
func get_movement(actor: CharacterBody2D, speed) -> Vector2:
	var mouse_pos = actor.get_global_mouse_position()
	var distance = actor.global_position.distance_to(mouse_pos)
	var max_distance = 150
	
	if distance > 10.0:
		var current_speed = remap(distance, 10.0, max_distance, 0.0, speed)
		current_speed = clamp(current_speed, 0.0, speed)
		return actor.global_position.direction_to(mouse_pos) * current_speed
	
	return Vector2.ZERO
