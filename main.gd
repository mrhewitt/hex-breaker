extends Control

#@onready var title_screen: Control = $TitleScreen
@onready var world: VBoxContainer = $World


func _on_play_button_body_play_pressed() -> void:
	#title_screen.visible = false
	world.visible = true
