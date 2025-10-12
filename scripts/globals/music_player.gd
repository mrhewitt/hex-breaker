extends Node

# dictionary of single sounds to be used with play(...)
var MUSIC = {
	theme = preload("res://assets/audio/Sakura-Girl-Stars-chosic.com_.ogg"),
	game = [
		preload("res://assets/audio/Sakura-Girl-Daisy-chosic.com_.ogg"),
		preload("res://assets/audio/Sakura-Girl-Wake-Up-chosic.com_.ogg"),
		preload("res://assets/audio/Small-Town(chosic.com).ogg")
	]
}

var _music_audio_player: AudioStreamPlayer = null
var available_game_tracks: Array = []


func play_theme() -> void:
	play_stream( MUSIC.theme )
	

# play a random track, and remove it from list, this way we play all
# tracks once every 3 cycles, but it is still random
func play_game_track() -> void:
	# if all game music tracks have played, restart to full list
	if available_game_tracks.size() == 0:
		available_game_tracks = [0,1,2]
	var track = available_game_tracks.pick_random()
	available_game_tracks.erase(track)
	play_stream(MUSIC.game[track], false)
	# when music is done, loop back to play another random game track
	_music_audio_player.connect("finished", play_game_track)
	
	
func play_stream(sound_to_play: AudioStream, loop: bool = true) -> void:
	# create a new audio player and put it in the scene
	# if you forgot to add_child() to incklude it in a scene
	# your sound will not play 
	if _music_audio_player == null:
		_music_audio_player = AudioStreamPlayer.new()
		get_tree().get_current_scene().add_child.call_deferred(_music_audio_player)
		# tell it to start playing the sound we chose
		_music_audio_player.bus = "Music"
		if loop:
			_music_audio_player.connect("finished", _on_music_finished)
		
	_music_audio_player.stream = sound_to_play
	_music_audio_player.play.call_deferred() 
	
	
func _on_music_finished() -> void:
	_music_audio_player.play()
