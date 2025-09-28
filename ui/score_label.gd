extends Label

@export var highlight_color: Color
@export var bump_font_size: int

var default_font_size: int

func _ready() -> void:
	GameManager.score_updated.connect(_on_update_score)
	default_font_size = get_theme_font_size("font_size")


func _on_update_score(score_added: int, total_score: int) -> void:
	text = "%05d" % total_score
	var tween = create_tween().set_parallel()
	tween.tween_property(self,"self_modulate",highlight_color,0.05)
	tween.tween_property(self,"theme_override_font_sizes/font_size", 110, 0.075)
	tween.finished.connect( reset_score_label )
	
	var point_label = Label.new()
	var one_third_portion: float = get_rect().size.x/3
	point_label.position.x += randf_range(one_third_portion,one_third_portion*2)
	point_label.text = "+" + str(score_added)
	point_label.self_modulate = highlight_color
	point_label.add_theme_font_size_override("font_size",48)
	add_child(point_label)
	
	var label_tween = create_tween().set_parallel()
	label_tween.tween_property(point_label,"self_modulate:a",0,0.6)
	label_tween.tween_property(point_label,"position:y", -150, 0.6)
	label_tween.finished.connect( point_label.queue_free )



func reset_score_label() -> void:
	self_modulate = Color.WHITE
	add_theme_font_size_override("font_size",default_font_size)
