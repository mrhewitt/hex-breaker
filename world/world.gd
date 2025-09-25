extends VBoxContainer

@onready var level: Control = $Level
@onready var round_label: Label = $HUDUpper/RoundLabel


func _ready() -> void:
	BlockSpawner.level_updated.connect(_on_level_updated)
	BlockSpawner.set_level_node(level)
	BlockSpawner.init_level()


func _on_level_updated(_level: int) -> void:
	round_label.text = str(_level)
