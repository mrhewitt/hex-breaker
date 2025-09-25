extends Node

# list of sounds to be used with play_random, a sound will be selected at random
# from list of options for given key
const SFX_RANDOM = {

}

# dictionary of single sounds to be used with play(...)
var SFX = {

}

func play( sound_key: String ) -> void:
	if SFX.has(sound_key):
		play_stream( SFX[sound_key] )
	else:
		print("SfxPlayer: Invalid sound key for play - " + sound_key)


func play_random( group: String ) -> void:
	var sfx_list: Array = SFX_RANDOM.get(group)
	if sfx_list and sfx_list.size() > 0:
		play_stream( sfx_list.pick_random() )
	else:
		print("SfxPlayer: Invalid sound group for play_random: " + group)


func play_stream(sound_to_play: AudioStream) -> void:
	# create a new audio player and put it in the scene
	# if you forgot to add_child() to incklude it in a scene
	# your sound will not play 
	var stream = AudioStreamPlayer.new()
	get_tree().get_current_scene().add_child(stream)
	# tell it to start playing the sound we chose
	stream.bus = "SFX"
	stream.stream = sound_to_play
	stream.play() 
	# wait for "finished" signal so we can know when it is done
	await stream.finished
	# delete sound player from scene so finished players dont simply continue to pile up
	stream.queue_free()
