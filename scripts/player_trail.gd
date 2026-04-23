extends Line2D
class_name PlayerTrail

@export var max_points: int = 300
@export var min_sample_distance: float = 5.0
@export var intersection_skip_points: int = 10
@export var trail_width: float = 4.0
@export var trail_color: Color = Color(0.2, 0.8, 1.0, 1.0)

var _trail: Array[Vector2] = []
var _player: Node2D


func _ready() -> void:
	top_level = true
	width = trail_width
	default_color = trail_color


func _process(_delta: float) -> void:
	if not _player:
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if not _player:
			print("no player found by player trail")
			return

	_sample(_player.global_position)
	_check_intersection()
	_redraw()



func _sample(pos: Vector2) -> void:
	if _trail.is_empty() or _trail.back().distance_to(pos) >= min_sample_distance:
		_trail.append(pos)
		if _trail.size() > max_points:
			_trail.pop_front()


func _redraw() -> void:
	clear_points()
	for p in _trail:
		add_point(p)


func _check_intersection() -> void:
	var n := _trail.size()
	if n < intersection_skip_points + 3:
		return

	var a := _trail[n - 2]
	var b := _trail[n - 1]

	var check_limit := n - 2 - intersection_skip_points
	for i in range(check_limit):
		var hit = _segment_intersect(a, b, _trail[i], _trail[i + 1])
		if hit == null:
			continue

		# build the closed polygon 
		# intersection point -> trail tip -> back
		var polygon := PackedVector2Array()
		polygon.append(hit)
		for j in range(i + 1, n):
			polygon.append(_trail[j])

		var caught: Array[Node] = []
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy is Node2D:
				if Geometry2D.is_point_in_polygon((enemy as Node2D).global_position, polygon):
					caught.append(enemy)

		_spawn_loop_particles(polygon)
		SignalHandler.loop_formed.emit(caught)
		print("LOOP FORMED")

		# reset player starts a new trail from the intersection
		_trail = [hit]
		return


func _spawn_loop_particles(polygon: PackedVector2Array) -> void:
	var template := get_parent().get_node_or_null("PlayerTrailLoopParticles") as CPUParticles2D
	if not template:
		return
	var scene_root := get_tree().current_scene
	for point in polygon:
		var p := template.duplicate() as CPUParticles2D
		scene_root.add_child(p)
		p.global_position = point
		p.emitting = true
		get_tree().create_timer(p.lifetime + 0.5).timeout.connect(p.queue_free)


# returns the intersection point of segments (p1->p2) and (p3->p4) or null
func _segment_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> Variant:
	var d1 := p2 - p1
	var d2 := p4 - p3
	var denom := d1.cross(d2)
	if abs(denom) < 0.001:
		return null
	var diff := p3 - p1
	var t := diff.cross(d2) / denom
	var u := diff.cross(d1) / denom
	if t > 0.001 and t < 0.999 and u > 0.001 and u < 0.999:
		return p1 + d1 * t
	return null
