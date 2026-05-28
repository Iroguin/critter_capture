extends Node

const HOTSPOT = Vector2(0, 0)
# Hardware cursors render at the texture's native size, so we resample the
# 64x64 source art to this scale. 0.5 = half size.
const CURSOR_SCALE = 0.5

var _cursor_normal := _scaled(preload("res://assets/sprites/misc/cursor/cursor_cc_normal.png"))
var _cursor_hover  := _scaled(preload("res://assets/sprites/misc/cursor/cursor_cc_hover.png"))
var _cursor_click  := _scaled(preload("res://assets/sprites/misc/cursor/cursor_cc_click.png"))


func _scaled(source: Texture2D) -> Texture2D:
	if CURSOR_SCALE == 1.0:
		return source
	var img := source.get_image()
	img.resize(
		int(img.get_width() * CURSOR_SCALE),
		int(img.get_height() * CURSOR_SCALE),
		Image.INTERPOLATE_LANCZOS
	)
	return ImageTexture.create_from_image(img)

# Buttons use CURSOR_ARROW by default, so we drive everything through that one
# shape and decide which texture it shows from these two flags. Click wins.
var _hovering: bool = false
var _clicking: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply()
	# Hook every button that exists now, and any added later (e.g. after a
	# scene change), so individual buttons never need their cursor shape set.
	get_tree().node_added.connect(_on_node_added)
	_hook_existing_buttons()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_clicking = event.pressed
		_apply()


func _apply() -> void:
	var texture: Texture2D = _cursor_normal
	if _clicking:
		texture = _cursor_click
	elif _hovering:
		texture = _cursor_hover
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, HOTSPOT)


func _hook_existing_buttons() -> void:
	for node in get_tree().root.find_children("*", "BaseButton", true, false):
		_hook_button(node)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node)


func _hook_button(button: BaseButton) -> void:
	if not button.mouse_entered.is_connected(_on_button_mouse_entered):
		button.mouse_entered.connect(_on_button_mouse_entered)
	if not button.mouse_exited.is_connected(_on_button_mouse_exited):
		button.mouse_exited.connect(_on_button_mouse_exited)


func _on_button_mouse_entered() -> void:
	_hovering = true
	_apply()


func _on_button_mouse_exited() -> void:
	_hovering = false
	_apply()
