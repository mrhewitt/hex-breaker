extends Node

# High Score Maanager
# @todo  -  Port code from GameManager to more resuable manager here

signal high_score_updated(high_score: int)

# prefix/suffixes for usernames in case player does not enter anything
# for his name we will generate a random one
const PREFIX: Array[String] = [
	"Dark",
	"Zany",
	"Giggle",
	"Bad",
	"Hairy",
	"Frosted",
	"Wobbly",
	"Wacky",
	"Sir",
	"Miss",
	"Dancing",
	"Captain",
	"Ninja",
	"Grumpy"
]

const SUFFIX: Array[String] = [
	"Banana",
	"Zuchini",
	"Jelly",
	"Cupcake",
	"Potato",
	"Noodles",
	"Taco",
	"Penguin",
	"Turtle",
	"Chicken",
	"Wombat",
	"Goose"
]
		
var high_score: int = 0:
	set(high_score_in):
		# ensure we only update high score it better, we do it here to prevent external
		# sources needing to always do this check, but we have a special case for 0
		# so that we can reset the high score to empty
		if high_score_in == 0 or high_score_in > high_score:
			high_score = high_score_in
			high_score_updated.emit(high_score)
		
var top_player: Dictionary 

var high_score_list: Array[Dictionary]


func get_random_player_name() -> String:
	return PREFIX.pick_random() + " " + SUFFIX.pick_random()
	
	
func get_api_key() -> String:
	var file_path = "res://data/api_key.txt" # Adjust path as needed
	var file = FileAccess.open(file_path, FileAccess.READ)

	if file:
		var key:String = file.get_as_text().strip_edges() # Reads the entire file as a single string
		file.close()
		#print("API KEY: >>>>>" + key + "<<<<<")
		return key
	else:
		return ""


func load_high_scores() -> void:
	#await get_tree().create_timer(1).timeout
	#set_high_score_list([{name="Bob",score=950}])
	#return
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform a GET request. The URL below returns JSON as of writing.
	var api_key: String = "X-Master-key: " + get_api_key()
	var error = http_request.request(			\
		"https://api.jsonbin.io/v3/b/68b974cfd0ea881f4071608d?meta=false",			\
		[api_key, "X-Bin-Meta:false"]
	)
	if error != OK:
		print("An error occurred in the HTTP request.")
		

func save_high_score( player_name: String, _score: int ) -> void:
	high_score_list.append( {name=player_name, score=_score} )
	high_score_list.sort_custom( sort_high_scores )
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform a GET request. The URL below returns JSON as of writing.
	var api_key: String = "X-Master-key: " + get_api_key()
	http_request.request(			\
		"https://api.jsonbin.io/v3/b/68b974cfd0ea881f4071608d?meta=false",			\
		[api_key, "X-Bin-Meta:false", "Content-Type: application/json"],			\
		HTTPClient.Method.METHOD_PUT,
		JSON.stringify(high_score_list)
	)


# Called when the HTTP request is completed.
func _http_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# parse json into an array of score dictionaries ...
	# [ {name:xxx, score:000.00},..]
	var scores = json.get_data()
	set_high_score_list( scores if scores is Array else scores.record )
	
	
func set_high_score_list( _scores: Array ) -> void:
	# parse into high score array, Godot does not like to assign it direct, plus
	# by default json is parsing number as floats, so force convert to int to proceed 
	high_score_list = []
	for _score in _scores:
		high_score_list.append( {name=_score.name, score=int(_score.score)} )
		
	# update high scores and top player info for UI and data updates	
	if high_score_list.size():
		high_score = high_score_list[0].score
		top_player = high_score_list[0]
	else:
		high_score = 0
		
		
func makes_highscore_list( _score: int ) -> bool:
	if high_score_list.size() < 10:
		return true
	else:
		for entry in high_score_list:
			if _score > entry.score:
				return true
		return false
	
	
func sort_high_scores(score_a, score_b) -> bool:
	return score_b.score < score_a.score
