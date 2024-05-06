extends Label


func _ready() -> void:
	if GameManager.highscores_save_data.highscores.size() > 0:
		text = str(GameManager.highscores_save_data.highscores[0][1])
	else:
		text = str(0)
