extends Label


func _ready() -> void:
	text = str(GameManager.highscores_save_data.highscores[0][1])
