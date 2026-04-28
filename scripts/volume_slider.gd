extends HSlider

# use exact same name as adio bus ("Master", SFX")
@export var bus_name: String
var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	
	# init the slider position based on the current bus volume
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
	# connect slider signal to update volume when dragged
	value_changed.connect(_on_value_changed)

func _on_value_changed(slider_value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(slider_value))
