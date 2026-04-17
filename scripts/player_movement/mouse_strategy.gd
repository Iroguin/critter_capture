# mouse_strategy.gd
extends MovementStrategy
class_name MouseStrategy

var target_position: Vector2

# mouse movement logic
func get_movement(actor: CharacterBody2D, speed) -> Vector2:
	var mouse_pos = actor.get_global_mouse_position()
	var distance = actor.global_position.distance_to(mouse_pos)
	
	if distance > 10.0:
		return actor.global_position.direction_to(mouse_pos) * speed
	
	return Vector2.ZERO
