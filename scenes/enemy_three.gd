extends Enemy

var x_val = self.position.x
var y_val = self.position.y
var screen_width = get_viewport_rect().size.x
var screen_height = get_viewport_rect().size.y

var center = Vector2(screen_width/2, screen_height/2)
var radius = 60
var theta = 0

var suuri = true

func _physics_process(delta: float) -> void:
	if suuri:
		radius += 10*delta
	else:
		radius -= 10*delta
	
	theta = 10*delta
	
	var new_position = center + Vector2(cos(theta), sin(theta))*radius
	
	if x_val >= screen_width or x_val <= 0 or y_val >= screen_height or y_val <= 0:
		suuri != suuri
	move_and_slide()
