extends Control

const WORLD = preload("uid://c1h3cc75cwin8")

@onready var title_screen: Control = $TitleScreen


func _ready() -> void:
	MusicPlayer.play('theme')


func show_title_screen() -> void:
	MusicPlayer.play('theme')
	title_screen.fade_in()
	
	
func _on_play_button_body_play_started() -> void:
	title_screen.visible = false
	
	# create world scene dynamically, for some reason if it is added
	# manually to main scene tree the top and bottom boundary walls do not
	# size their collision shapes correctly 
	var world := WORLD.instantiate()
	world.title_screen.connect(show_title_screen)
	add_child(world)
	world.visible = true
	world.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(world,'modulate:a',1,0.65)
	await tween.finished
	
	world.start_new_game()
