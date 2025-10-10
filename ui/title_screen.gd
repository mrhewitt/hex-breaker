extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var play_button_body: CharacterBody2D = $PlayButtonBody


func _on_play_button_body_play_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(texture_rect, 'modulate:a', 0, 0.6)


func fade_in() -> void:
	modulate.a = 0
	visible = true
	play_button_body.reset()
	texture_rect.modulate.a = 1
	var tween = create_tween()
	tween.tween_property(self, 'modulate:a',1,0.65)
