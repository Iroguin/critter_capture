extends Area2D


@export var speed: float = 220.0
@export var damage: float = 1.0
@export var lifetime: float = 5.0
@export var spin_speed: float = 180.0  # degrees/sec

var direction: Vector2 = Vector2.RIGHT
var age: float = 0.0


func launch(dir: Vector2) -> void:
	if dir.length() > 0.001:
		direction = dir.normalized()


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation_degrees += spin_speed * delta

	age += delta
	if age >= lifetime or _is_off_screen():
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()


func _is_off_screen() -> bool:
	var screen := get_viewport_rect().size
	var margin := 64.0
	var pos := global_position
	return pos.x < -margin or pos.x > screen.x + margin \
		or pos.y < -margin or pos.y > screen.y + margin
