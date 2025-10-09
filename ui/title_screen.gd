extends Control

@onready var texture_rect: TextureRect = $TextureRect


func _on_play_button_body_play_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(texture_rect, 'modulate:a', 0, 0.6)
