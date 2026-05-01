extends Node

signal loop_formed(caught_enemies: Array[Node])
signal trail_color_changed(color: Color)
signal enemy_captured(points: int)
signal game_over(points:int, time:float)
signal background_changed()
