extends Enemy

var player = null

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
 
func _physics_process(delta: float) -> void:
	var player_velocity = player.velocity*1.3
	velocity = player_velocity
	move_and_slide()
	print(player)
