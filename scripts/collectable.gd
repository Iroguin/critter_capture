extends Node2D
class_name Collectable


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_on_pickup(body)
		queue_free()


func _on_pickup(_player: Node2D) -> void:
	pass
