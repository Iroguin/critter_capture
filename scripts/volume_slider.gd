extends HSlider

# use exact same name as adio bus ("Master", SFX")
@export var bus_name: String
var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value = GameConfig.get_volume(bus_name)
	value_changed.connect(_on_value_changed)

func _on_value_changed(slider_value: float) -> void:
	GameConfig.set_volume(bus_name, slider_value)
