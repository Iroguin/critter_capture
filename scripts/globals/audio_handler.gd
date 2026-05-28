extends Node

const CLICK_SFX = "res://assets/audio/625271__gabriel_dornelles__menu-sfx-1.ogg"

var _sounds = {}
var _music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)


func play_sfx(stream_path: String, bus: String = "SFX", pitch: float = 1.0):
	# load the resource if not already cached
	if not _sounds.has(stream_path):
		_sounds[stream_path] = load(stream_path)
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = _sounds[stream_path]
	player.bus = bus
	player.pitch_scale = pitch

	# clean up the node when finished
	player.finished.connect(player.queue_free)

	player.play()


func play_music(stream_path: String) -> void:
	# load the resource if not already cached
	if not _sounds.has(stream_path):
		_sounds[stream_path] = load(stream_path)
	var stream = _sounds[stream_path]
	# don't restart if this track is already playing
	if _music_player.playing and _music_player.stream == stream:
		return
	_music_player.stream = stream
	_music_player.play()


func play_click() -> void:
	play_sfx(CLICK_SFX, "UI")
