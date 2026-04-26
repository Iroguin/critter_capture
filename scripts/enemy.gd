extends CharacterBody2D
class_name Enemy

@export var contact_damage : float
@export var max_health : float
@export var move_speed : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collision_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(contact_damage)

func die():
	SignalHandler.enemy_captured.emit(1) # number int is points for highscore, placehonder 1
	queue_free()
