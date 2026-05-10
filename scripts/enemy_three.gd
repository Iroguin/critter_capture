extends Enemy

var radius:float = 600
var angle:float = 0.0
var speed:float = 1.5
var _X_OFFSET = 900
var _Y_OFFSET = 500
var larger:float = 50

func _physics_process(delta: float) -> void:
	circular_motion()
	
func circular_motion():
	speed += 0.1 * get_process_delta_time()
	angle += speed * get_process_delta_time() 
	if radius > -500:
		radius -= larger * get_process_delta_time()
	var x_pos = cos(angle)
	var y_pos = sin(angle)
	
	
	position.x = radius * x_pos + _X_OFFSET
	position.y = radius * y_pos + _Y_OFFSET
	
	
	
	
	

	
	
