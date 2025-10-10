extends Node

const BLOCK_BURST = 'block_burst'
const BONUS_LEAVE = 'bonus_leave'
const START_CLICK = 'start_click'
const BALL_BONUS = 'ball_bonus'
const SHIELD_BONUS = 'shield_bonus'
const SPLITTER_BONUS = 'splitter_bonus'
const PAUSE_BUTTON = 'pause_button'
const DROP_BUTTON = 'drop_button'
const MOVE_START_POINT = 'start_point'
const GAME_OVER = 'game_over'

# list of sounds to be used with play_random, a sound will be selected at random
# from list of options for given key
const SFX_RANDOM = {
	BLOCK_BURST: [
		preload("res://assets/audio/Balloon_Pop-003.ogg"),
		preload("res://assets/audio/Balloon_Pop-004.ogg"),
		preload("res://assets/audio/Balloon_Pop-005.ogg")
	]
}

# dictionary of single sounds to be used with play(...)
var SFX = {
	BONUS_LEAVE: preload("res://assets/audio/Movement_Whoosh_Long-005.ogg"),
	START_CLICK: preload("res://assets/audio/Synth_Button-015.ogg"),
	BALL_BONUS: preload("res://assets/audio/Positive_Button_Collect_-022.ogg"),
	SHIELD_BONUS: preload("res://assets/audio/Power_UP-010.ogg"),
	SPLITTER_BONUS: preload("res://assets/audio/Bounce_Boing-008.ogg"),
	PAUSE_BUTTON: preload("res://assets/audio/Chimes_Harp-017.ogg"),
	DROP_BUTTON: preload("res://assets/audio/Power_DOWN-008.ogg"),
	MOVE_START_POINT: preload("res://assets/audio/Movement_Whoosh_Short-017.ogg"),
	GAME_OVER: preload("res://assets/audio/Losing_Jingle-026.ogg")
}

func play( sound_key: String ) -> void:
	if SFX.has(sound_key):
		play_stream( SFX[sound_key] )
	else:
		print("SfxPlayer: Invalid sound key for play - " + sound_key)


func play_to_node( sound_key: String, parent: Node ) -> void:
	if SFX.has(sound_key):
		play_stream( SFX[sound_key], parent)
	else:
		print("SfxPlayer: Invalid sound key for play - " + sound_key)


func play_random( group: String) -> void:
	var sfx_list: Array = SFX_RANDOM.get(group)
	if sfx_list and sfx_list.size() > 0:
		play_stream( sfx_list.pick_random() )
	else:
		print("SfxPlayer: Invalid sound group for play_random: " + group)


func play_stream(sound_to_play: AudioStream, parent: Node = null ) -> void:
	# create a new audio player and put it in the scene
	# if you forgot to add_child() to incklude it in a scene
	# your sound will not play 
	var stream = AudioStreamPlayer.new()
	if parent == null:
		get_tree().get_current_scene().add_child(stream)
	else:
		parent.add_child(stream)
	# tell it to start playing the sound we chose
	stream.bus = "SFX"
	stream.stream = sound_to_play
	stream.play() 
	# wait for "finished" signal so we can know when it is done
	await stream.finished
	# delete sound player from scene so finished players dont simply continue to pile up
	stream.queue_free()
