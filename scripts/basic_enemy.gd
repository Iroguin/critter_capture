extends Enemy

var x_val = self.pos.x
var y_val = self.pos.y
var screen_width = get_viewport_rect().size.x
var screen_height = get_viewport_rect().size.y

func _process(delta: float) -> void:
	if is_on_wall():
		if x_val >= screen_width or x_val <= 0:
			velocity.x = move_speed*-1
		if y_val >= screen_height or y_val <= 0:
			velocity.y = move_speed*-1

	move_and_slide()
