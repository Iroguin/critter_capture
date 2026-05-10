extends CharacterBody2D
class_name Enemy

@export var contact_damage : float
@export var max_health : float
@export var move_speed : float
@export var use_sprite_average_color: bool = true
@export var death_color_override: Color = Color(1, 1, 1, 1)
# the sprite must always be called Enemy_Sprite
@onready var sprite: Sprite2D = $Enemy_Sprite
@onready var death_particles: CPUParticles2D = $Enemy_Death_Particles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")
	start_sway_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass


func _on_collision_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(contact_damage)

func die():
	SignalHandler.enemy_captured.emit(1) # number int is points for highscore, placehonder 1
	_spawn_death_explosion()
	queue_free()


func _spawn_death_explosion() -> void:
	if not death_particles:
		return
	var scene_root := get_tree().current_scene
	if not scene_root:
		return
	var explosion := death_particles.duplicate() as CPUParticles2D
	explosion.process_mode = Node.PROCESS_MODE_ALWAYS
	explosion.color = resolve_death_color()
	explosion.emitting = true
	scene_root.add_child(explosion)
	explosion.global_position = global_position
	get_tree().create_timer(explosion.lifetime + 0.5).timeout.connect(explosion.queue_free)


func resolve_death_color() -> Color:
	if not use_sprite_average_color:
		return death_color_override
	return _get_average_color(sprite)

func _get_average_color(sprite: Sprite2D) -> Color:
	var img = sprite.texture.get_image()
	var r_total = 0.0
	var g_total = 0.0
	var b_total = 0.0
	var count = 0

	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var pixel = img.get_pixel(x, y)
			if pixel.a > 0.1:
				r_total += pixel.r
				g_total += pixel.g
				b_total += pixel.b
				count += 1

	if count == 0: return Color.WHITE
	return Color(r_total / count, g_total / count, b_total / count)

func start_sway_animation():
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "rotation_degrees", 5.0, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "rotation_degrees", -5.0, 1.0).set_trans(Tween.TRANS_SINE)
