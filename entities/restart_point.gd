extends Area2D
class_name RestartPoint

signal restart_point_selected


func _input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event.is_action_pressed("ui_touch"):
		restart_point_selected.emit()
