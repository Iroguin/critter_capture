extends Control
class_name HSVWheel

signal hue_saturation_changed(hue: float, sat: float)

const SEGMENTS := 64

var hue: float = 0.0:
	set(value):
		hue = value
		queue_redraw()
var saturation: float = 0.0:
	set(value):
		saturation = value
		queue_redraw()

var _dragging: bool = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			if event.pressed:
				_pick(event.position)
	elif event is InputEventMouseMotion and _dragging:
		_pick(event.position)


func _pick(pos: Vector2) -> void:
	var center := size * 0.5
	var offset := pos - center
	var radius := minf(center.x, center.y)
	if radius <= 0.0:
		return
	var r := minf(offset.length() / radius, 1.0)
	var a := offset.angle() / TAU
	if a < 0.0:
		a += 1.0
	hue = a
	saturation = r
	hue_saturation_changed.emit(hue, saturation)


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(center.x, center.y)
	if radius <= 0.0:
		return

	for i in SEGMENTS:
		var a0 := float(i) / SEGMENTS * TAU
		var a1 := float(i + 1) / SEGMENTS * TAU
		var p0 := center + Vector2.from_angle(a0) * radius
		var p1 := center + Vector2.from_angle(a1) * radius
		var c0 := Color.from_hsv(a0 / TAU, 1.0, 1.0)
		var c1 := Color.from_hsv(a1 / TAU, 1.0, 1.0)
		draw_polygon(
			PackedVector2Array([center, p0, p1]),
			PackedColorArray([Color.WHITE, c0, c1])
		)

	var marker_pos := center + Vector2.from_angle(hue * TAU) * (saturation * radius)
	draw_circle(marker_pos, 6.0, Color.WHITE)
	draw_arc(marker_pos, 6.0, 0.0, TAU, 32, Color.BLACK, 2.0)
