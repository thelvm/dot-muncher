extends Label

var last_score: int = 0
var score_display: int = 0
var score_display_tween: Tween


func _process(_delta: float) -> void:
	if last_score != GameManager.score:
		last_score = GameManager.score
		if score_display_tween:
			score_display_tween.kill()
		score_display_tween = create_tween()
		score_display_tween.tween_property(self, "score_display", GameManager.score, 0.1)
	
	text = "Score: " + str(score_display)
