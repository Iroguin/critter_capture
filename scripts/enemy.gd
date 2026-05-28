extends CharacterBody2D
class_name Enemy

const death_sfx = "res://assets/audio/328118__dsg__pop-7.wav"

@export var contact_damage : float
@export var max_health : float
@export var move_speed : float
@export var point_worth : int = 1
@export var use_sprite_average_color: bool = true
@export var death_color_override: Color = Color(1, 1, 1, 1)

@export_group("Animation")
# empty means using the sprite texture
@export var idle_frames: Array[Texture2D] = []
@export var idle_fps: float = 4.0
# named one-off poses
@export var special_sprites: Dictionary = {}

# the sprite must always be called Enemy_Sprite
@onready var sprite: Sprite2D = $Enemy_Sprite
@onready var death_particles: CPUParticles2D = $Enemy_Death_Particles

# Animation state
var _idle_index: int = 0
var _idle_timer: float = 0.0
var _playing_special: bool = false
var _special_timer: float = 0.0  # > 0 means auto-return to idle when it elapses

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")
	start_sway_animation()
	if not idle_frames.is_empty():
		sprite.texture = idle_frames[0]

# Animation is visual, so it runs in _process. Subclasses freely override
# _physics_process for movement without needing to call super().
func _process(delta: float) -> void:
	_update_animation(delta)


func _update_animation(delta: float) -> void:
	if _playing_special:
		if _special_timer > 0.0:
			_special_timer -= delta
			if _special_timer <= 0.0:
				return_to_idle()
		return
	if idle_frames.size() < 2 or idle_fps <= 0.0:
		return
	_idle_timer += delta
	var frame_duration := 1.0 / idle_fps
	while _idle_timer >= frame_duration:
		_idle_timer -= frame_duration
		_idle_index = (_idle_index + 1) % idle_frames.size()
		sprite.texture = idle_frames[_idle_index]


# Show a named special pose. If hold_time > 0 the enemy auto-returns to the
# idle cycle after that many seconds; otherwise it holds until return_to_idle().
func play_special(special_name: String, hold_time: float = 0.0) -> void:
	if not special_sprites.has(special_name):
		push_warning("Enemy has no special sprite named '%s'" % special_name)
		return
	_playing_special = true
	_special_timer = hold_time
	sprite.texture = special_sprites[special_name]


func return_to_idle() -> void:
	_playing_special = false
	_special_timer = 0.0
	_idle_timer = 0.0
	if not idle_frames.is_empty():
		sprite.texture = idle_frames[_idle_index]


func _on_collision_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(contact_damage)

func die(multiplier: int = 1) -> void:
	AudioHandler.play_sfx(death_sfx, "SFX")
	SignalHandler.enemy_captured.emit(point_worth * multiplier)
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
