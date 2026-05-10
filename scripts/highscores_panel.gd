extends PanelContainer

@onready var _label: RichTextLabel = $MarginContainer/Highscores_Label


func _ready() -> void:
	refresh()


func refresh(highlight_date: int = -1) -> void:
	_label.text = GameConfig.get_formatted_highscores(10, highlight_date)
