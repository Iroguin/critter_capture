extends Resource
class_name EnemyStage

@export var time_threshold: float = 0.0
@export var spawn_interval: float = 1.5
@export var enemy_scenes: Array[PackedScene] = []
@export var enemy_weights: Array[float] = []
