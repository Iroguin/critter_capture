extends CharacterBody2D

const SPEED = 300.0

@export var health := 1.0


# the default movement is wasd MovementStrategy is a class
var current_strategy: MovementStrategy = WASDStrategy.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# current strategy governs movement it can be found in "res://scripts/player_movement/"
	velocity = current_strategy.get_movement(self, SPEED)
	move_and_slide()

func take_damage(damage):
	health -= damage
	if health <= 0.0:
		die()
	print("remaining health: " + str(health))


func die():
	print("YOU DIED")


func _on_player_trail_loop_formed(caught_enemies: Array[Node]) -> void:
	print("Captured %d enemies!" % caught_enemies.size())
	for enemy in caught_enemies:
		if enemy.has_method("die"):
			enemy.die()


func _on_pause_menu_movement_mode_changed(use_mouse: bool) -> void:
	if use_mouse:
		current_strategy = MouseStrategy.new()
	else:
		current_strategy = WASDStrategy.new()
