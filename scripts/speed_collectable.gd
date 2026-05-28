extends Collectable
class_name SpeedCollectable

@export var speed_multiplier: float = 1.5
@export var duration: float = 5.0
@export var spin_speed: float = 1.0

@onready var triangle: Polygon2D = $Triangle


func _process(delta: float) -> void:
	if triangle:
		triangle.rotation += spin_speed * delta
		triangle.position.y = sin(Time.get_ticks_msec() * 0.003) * 4.0



func _on_pickup(player: Node2D) -> void:
	if player.has_method("apply_speed_boost"):
		player.apply_speed_boost(speed_multiplier, duration)
