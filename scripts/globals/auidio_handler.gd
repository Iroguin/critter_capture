extends Node

var _sounds = {}

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
