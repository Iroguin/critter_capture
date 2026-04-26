extends CharacterBody2D

const SPEED = 300.0

@export var health := 1.0


# the default movement is wasd MovementStrategy is a class
var current_strategy: MovementStrategy = WASDStrategy.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	SignalHandler.loop_formed.connect(_on_loop_formed)

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


func _on_loop_formed(caught_enemies: Array[Node]) -> void:
	for node in caught_enemies:
		if node is Enemy:
			(node as Enemy).die()


func _on_pause_menu_movement_mode_changed(mode: String) -> void:
	match mode:
		"Mouse": current_strategy = MouseStrategy.new()
		"Free Move": current_strategy = FreeMoveStrategy.new()
		_: current_strategy = WASDStrategy.new()
