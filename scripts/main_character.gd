extends CharacterBody2D

const SPEED = 300.0

@export var health := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var xdirection := Input.get_axis("ui_left", "ui_right")
	var ydirection := Input.get_axis("ui_up", "ui_down")
	if xdirection:
		velocity.x = xdirection * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if ydirection:
		velocity.y = ydirection * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

func take_damage(damage):
	health -= damage
	if health <= 0.0:
		die()
	print("remaining health: " + str(health))


func die():
	print("YOU DIED")
