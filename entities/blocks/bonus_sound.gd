extends Node

@export var sfx_name: String

@onready var cooldown_timer: Timer = $CooldownTimer

func play() -> void:
	if sfx_name != '' and cooldown_timer.is_stopped():
		SfxPlayer.play(sfx_name)
		cooldown_timer.start()
