extends Sprite2D

@export var outline_color: Color = Color("efff2f")

var outline_tween: Tween = null


func show_outline() -> void:
	self_modulate = outline_color
	visible = true
	
	# if tween is already playing when we are hit, stop it and reset outline
	# color so we can show a full new hit
	if outline_tween != null:
		outline_tween.kill()
		
	outline_tween = create_tween()
	outline_tween.tween_property(self,'self_modulate:a',0,0.2)
	outline_tween.finished.connect(hide)
