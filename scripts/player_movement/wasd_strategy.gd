# wasd_strategy.gd
extends MovementStrategy
class_name WASDStrategy

# WASD movement logic
func get_movement(actor: CharacterBody2D, speed) -> Vector2:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return dir * speed
