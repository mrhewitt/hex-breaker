extends BonusBlock
class_name ShieldBonusBlock

@export var icon_highlight_color: Color
 
@onready var icon_sprite: Sprite2D = $IconSprite


func _ready() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_loops()
	tween.tween_property(icon_sprite, 'modulate', icon_highlight_color, 0.2)
	tween.tween_property(icon_sprite, 'modulate', Color.WHITE, 0.2)
	
	
# every ball that makes contact gets a shield to allow one extra bounce off base wall
# remains on screen until level end, balls can power up multiple times
func block_hit(body: BouncingBall) -> bool:
	body.has_bounce_shield = true
	return true
