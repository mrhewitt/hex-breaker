extends Node

signal score_updated(score: int)
#signal top_player_updated(top_player: Dictionary)

var score: int = 0:
	set(score_in):
		score = score_in
		HighScoreManager.high_score = score
		score_updated.emit(score)



#var high_score_list: Array[Dictionary] = [{name="Bob",score=10223},{name="Adian1",score=3912},{name="Predator88518",score=324}]


# extra margin added at top to move entire game down on mobile
# devies, whilst safe margin is needed this is really a hack as
# I only added direct mobile support at end, and found I needed to shirt entire
# layout down to compensate for mobile resolutions, so to keep game fair 
# (same size playing field) components added at start (invader grid/paddle) and 
# death/bouncce areas alll shift down by safe margin, so game field remains same
# with a larger gap at top
var safe_margin: float = 0


func is_on_mobile() -> bool:
	return OS.get_name() in ["Android", "iOS"]


func new_game() -> void:
	score = 0
	
