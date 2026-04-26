extends MovementStrategy
class_name FreeMoveStrategy

func get_movement(actor: CharacterBody2D, _speed) -> Vector2:
	actor.global_position = actor.get_global_mouse_position()
	return Vector2.ZERO
