extends StaticBody2D
class_name Block

@export var hits: int = 1:
	set(hits_in):
		hits = hits_in
		if hit_count_label:
			hit_count_label.text = str(hits_in)

@export var grid_position: Vector2i:
	set(pos):
		grid_position = pos
		position = BlockSpawner.grid_to_pixel(grid_position)

@onready var hit_count_label: Label = %HitCountLabel



func take_hit() -> void:
	hits -= 1
	if hits <= 0:
		queue_free()
