extends Area2D
class_name RestartPoint

signal restart_point_selected

@export var show_click_hint: bool = false:
	set(hint):
		if click_hint:
			click_hint.visible = hint

@onready var click_hint: ClickHint = $ClickHint


func _input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event.is_action_pressed("ui_touch"):
		SfxPlayer.play(SfxPlayer.MOVE_START_POINT)
		restart_point_selected.emit()
