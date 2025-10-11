extends Control
class_name TutorialControl

@onready var tutorial_label: Label = $TutorialLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ball_marker_2d: Marker2D = $BallMarker2D
@onready var ball_sprite_2d: Sprite2D = $BallSprite2D
@onready var tutorial_level_1: Node2D = $TutorialLevel1


func show_tutorial(level: int, bonus_block: Node2D) -> void:
	hide_tutorials()
	visible = true
	
	if level == 1:
		show_default_tutorial()
	else:
		tutorial_label.text = bonus_block.tutorial_label
		start_ball_move_tween(bonus_block)		
	
	animation_player.play("tutorial_level_" + str(level))


func show_default_tutorial() -> void:
	tutorial_label.text = "Touch and Drag"
	tutorial_level_1.visible = true
	
	
func start_ball_move_tween(bonus_block: Node2D) -> void:
	var tween = create_tween().set_loops()
	ball_sprite_2d.visible = true
	tween.tween_property(ball_sprite_2d, 'global_position', bonus_block.global_position, 0.75).from(ball_marker_2d.global_position)
	tween.parallel().tween_property(ball_sprite_2d, 'modulate:a', 0, 0.75).from(1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)


func hide_tutorials() -> void:
	for node in get_children():
		if node.name.begins_with("TutorialLevel"):
			node.visible = false
	
