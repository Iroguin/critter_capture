extends Enemy

@export var hop_distance: float = 150.0
@export var hop_duration: float = 0.4
@export var idle_duration: float = 0.8
@export var hop_height: float = 30.0
@export var edge_margin: float = 100.0
# Each hop, sample this many candidate landing spots within hop_distance.
@export var hop_candidate_count: int = 8
# When the player is farther than this, the omenamato wanders randomly instead
# of fleeing. This prevents it from locking onto a "safest" corner forever:
# once the player walks away, it'll happily mill about and leave the corner.
@export var flee_distance: float = 350.0

@onready var drop_collectable: PackedScene = preload("res://scenes/collectables/speed_collectable.tscn")

enum State { IDLE, HOP }

var player: Node2D
var _state: int = State.IDLE
var _state_time: float = 0.0
var _hop_start: Vector2
var _hop_target: Vector2


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	_enter_state(State.IDLE)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_state_time += delta

	match _state:
		State.IDLE:
			if _state_time >= idle_duration:
				_start_hop()
		State.HOP:
			var t := minf(_state_time / hop_duration, 1.0)
			var pos := _hop_start.lerp(_hop_target, t)
			pos.y -= sin(t * PI) * hop_height
			global_position = pos
			if _state_time >= hop_duration:
				_enter_state(State.IDLE)


func _start_hop() -> void:
	# Two behaviors depending on threat level:
	#   - Player is close   -> sample candidates and pick the one farthest from
	#                          the player (flee).
	#   - Player is far     -> pick a random candidate (wander). This is what
	#                          breaks the corner lock-in: when the player walks
	#                          away, "farthest from player" stops anchoring us
	#                          to a corner and we just hop around freely.
	var screen := get_viewport_rect().size
	var player_distance := global_position.distance_to(player.global_position)
	var should_flee := player_distance < flee_distance

	var best_target := global_position
	var best_score := -INF

	for i in hop_candidate_count:
		# Random direction, random magnitude up to hop_distance — a disc of
		# candidates around us, so short hops stay viable.
		var offset := Vector2.from_angle(randf() * TAU) * randf() * hop_distance
		var candidate := global_position + offset
		candidate.x = clampf(candidate.x, edge_margin, screen.x - edge_margin)
		candidate.y = clampf(candidate.y, edge_margin, screen.y - edge_margin)
		# Wandering uses a random score so every candidate is equally appealing;
		# fleeing scores by player distance so the safest spot wins.
		var score := randf() if not should_flee else candidate.distance_to(player.global_position)
		if score > best_score:
			best_score = score
			best_target = candidate

	_hop_start = global_position
	_hop_target = best_target
	_enter_state(State.HOP)


func _enter_state(new_state: int) -> void:
	_state = new_state
	_state_time = 0.0
	if new_state == State.HOP:
		play_special("jump")
	else:
		return_to_idle()


func die(multiplier: int = 1) -> void:
	_drop_collectable()
	super(multiplier)


func _drop_collectable() -> void:
	if drop_collectable == null:
		return
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return
	var instance := drop_collectable.instantiate() as Node2D
	scene_root.add_child(instance)
	instance.global_position = global_position
