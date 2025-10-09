extends Node

signal score_updated(score_added:int, score: int)
#signal top_player_updated(top_player: Dictionary)

var score: int = 0:
	set(score_in):
		score = score_in
		HighScoreManager.high_score = score

# number of extra balls to add to total ball count at start of next round
var extra_balls: int = 0

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
	

# set score and emit set event, just assigning value does NOT emit event
# in propety setter as we dont know how many points were added, and we cannot
# send event twice, so this method just sets score, and delta is 0, add_to_score
# adds a delta to score and emits the new score with delta so we can do fx on it  
func set_score( _score: int ) -> void:
	score = _score
	score_updated.emit(0,score)
	
	
func add_to_score( points: int ) -> void:
	score += points
	score_updated.emit(points,score)
