extends VBoxContainer

signal title_screen
signal restart_game

@onready var level: Control = $Level
@onready var round_label: Label = $HUDUpper/RoundLabel
@onready var score_label: Label = %ScoreLabel
@onready var drop_button: Button = %DropButton
@onready var best_level_label: Label = %BestLevelLabel
@onready var best_score_label: Label = %BestScoreLabel
@onready var pause_control: Control = %PauseControl
@onready var game_over_control: Control = %GameOverControl

func start_new_game() -> void:
	MusicPlayer.play('game')
	
	GameManager.new_game()
	HighScoreManager.high_score_updated.connect(_on_new_highscore)
	_on_new_highscore(HighScoreManager.high_score)
	
	BlockSpawner.level_updated.connect(_on_level_updated)
	BlockSpawner.level_started.connect(_on_level_started)
	BlockSpawner.blocks_reached_bottom.connect(_on_game_over)
	BlockSpawner.set_level_node(level)
	BlockSpawner.init_level()


func _on_new_highscore(score: int) -> void:
	best_score_label.text = "Best Score: %05d" % score


func _on_level_updated(_level: int) -> void:
	round_label.text = str(_level)
	drop_button.disabled = true
	best_level_label.text = "Best Level: " + str(BlockSpawner.best_level)


func _on_drop_button_pressed() -> void:
	SfxPlayer.play(SfxPlayer.DROP_BUTTON)
	drop_button.disabled = true
	for ball in get_tree().get_nodes_in_group('bouncing_balls'):
		ball.drop_to_ground()
		
		
func _on_level_started() -> void:
	drop_button.disabled = false


func _on_game_over() -> void:
	SfxPlayer.play_to_node(SfxPlayer.GAME_OVER,game_over_control)
	get_tree().paused = true
	game_over_control.visible = true


func _on_pause_button_pressed() -> void:
	SfxPlayer.play(SfxPlayer.PAUSE_BUTTON)
	pause_control.visible = true
	get_tree().paused = true


func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	pause_control.visible = false
	

func _on_stop_button_pressed() -> void:
	get_tree().paused = false
	var tween = create_tween()
	tween.tween_property(self,'modulate:a',0,0.5)
	await tween.finished
	queue_free()
	title_screen.emit()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	game_over_control.visible = false
	queue_free()
	restart_game.emit()
