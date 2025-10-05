extends VBoxContainer

@onready var level: Control = $Level
@onready var round_label: Label = $HUDUpper/RoundLabel
@onready var score_label: Label = %ScoreLabel
@onready var drop_button: Button = %DropButton


func _ready() -> void:
	BlockSpawner.level_updated.connect(_on_level_updated)
	BlockSpawner.level_started.connect(_on_level_started)
	BlockSpawner.block_rows_full.connect(_on_game_over)
	BlockSpawner.set_level_node(level)
	BlockSpawner.init_level()


func _on_level_updated(_level: int) -> void:
	round_label.text = str(_level)
	drop_button.disabled = true
	

func _on_drop_button_pressed() -> void:
	for ball in get_tree().get_nodes_in_group('bouncing_balls'):
		ball.drop_to_ground()
		
		
func _on_level_started() -> void:
	drop_button.disabled = false
	
		
func _on_game_over() -> void:
	pass
