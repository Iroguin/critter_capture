extends HBoxContainer
class_name CustomColorPicker

signal color_changed(color: Color)

@onready var wheel: HSVWheel = $HSVWheel
@onready var r_slider: HSlider = $Sliders/RSlider
@onready var g_slider: HSlider = $Sliders/GSlider
@onready var b_slider: HSlider = $Sliders/BSlider
@onready var v_slider: HSlider = $Sliders/VSlider

var color: Color = Color.WHITE:
	set(value):
		color = value
		_apply_to_children()

var _syncing: bool = false


func _ready() -> void:
	wheel.hue_saturation_changed.connect(_on_wheel_changed)
	r_slider.value_changed.connect(_on_rgb_changed)
	g_slider.value_changed.connect(_on_rgb_changed)
	b_slider.value_changed.connect(_on_rgb_changed)
	v_slider.value_changed.connect(_on_value_changed)
	_apply_to_children()


func _apply_to_children() -> void:
	if wheel == null:
		return
	_syncing = true
	wheel.hue = color.h
	wheel.saturation = color.s
	r_slider.value = color.r
	g_slider.value = color.g
	b_slider.value = color.b
	v_slider.value = color.v
	_syncing = false


func _on_wheel_changed(h: float, s: float) -> void:
	if _syncing:
		return
	color = Color.from_hsv(h, s, v_slider.value, 1.0)
	color_changed.emit(color)


func _on_rgb_changed(_v: float) -> void:
	if _syncing:
		return
	color = Color(r_slider.value, g_slider.value, b_slider.value, 1.0)
	color_changed.emit(color)


func _on_value_changed(v: float) -> void:
	if _syncing:
		return
	color = Color.from_hsv(wheel.hue, wheel.saturation, v, 1.0)
	color_changed.emit(color)
