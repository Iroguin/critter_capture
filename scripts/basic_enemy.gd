extends Enemy

var x_val = self.position.x
var y_val = self.position.y
var screen_width = get_viewport_rect().size.x
var screen_height = get_viewport_rect().size.y

func _physics_process(delta: float) -> void:
	velocity.x = 100
	velocity.y = 100
	if is_on_wall():
		if x_val >= screen_width or x_val <= 0:
			velocity.x = move_speed*-1
		if y_val >= screen_height or y_val <= 0:
			velocity.y = move_speed*-1

	move_and_slide()
