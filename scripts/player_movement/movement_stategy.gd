# movement_strategy.gd
class_name MovementStrategy
extends RefCounted

# this simply defines the class so that it can be extended
func get_movement(actor: CharacterBody2D, speed) -> Vector2:
	return Vector2.ZERO
