extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var play_button_body: CharacterBody2D = $PlayButtonBody
@onready var sfx_button: TextureButton = $SfxButton
@onready var music_button: TextureButton = $MusicButton

const UI_SFX_BUTTON_DISABLED = preload("res://assets/ui-sfx-button-disabled.png")
const UI_SFX_BUTTON = preload("res://assets/ui-sfx-button.png")
const UI_SFX_BUTTON_HOVER = preload("res://assets/ui-sfx-button-hover.png")
const UI_SFX_BUTTON_HOVER_DISABLED = preload("res://assets/ui-sfx-button-hover-disabled.png")
const UI_MUSIC_BUTTON_DISABLED = preload("uid://bs8kn2xyedk08")
const UI_MUSIC_BUTTON_HOVER_DISABLED = preload("uid://bcjue8p8ts0wr")
const UI_MUSIC_BUTTON_HOVER = preload("uid://bth5iui55e3tf")
const UI_MUSIC_BUTTON = preload("uid://ds40p7ihpdpex")

func _on_play_button_body_play_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(texture_rect, 'modulate:a', 0, 0.6)
	sfx_button.visible = false
	music_button.visible = false
	

func fade_in() -> void:
	modulate.a = 0
	visible = true
	play_button_body.reset()
	texture_rect.modulate.a = 1
	var tween = create_tween()
	tween.tween_property(self, 'modulate:a',1,0.65)


func _on_sfx_button_pressed() -> void:
	SfxPlayer.mute = !SfxPlayer.mute
	sfx_button_state()
	

func _on_music_button_pressed() -> void:
	MusicPlayer.mute = !MusicPlayer.mute
	music_button_state()
	

func _on_visibility_changed() -> void:
	if sfx_button:
		sfx_button_state()
		music_button_state()
		
		
func sfx_button_state() -> void:
	sfx_button.visible = visible
	sfx_button.texture_normal = UI_SFX_BUTTON_DISABLED if SfxPlayer.mute else UI_SFX_BUTTON
	sfx_button.texture_hover = UI_SFX_BUTTON_HOVER_DISABLED if SfxPlayer.mute else UI_SFX_BUTTON_HOVER
	sfx_button.texture_pressed = UI_SFX_BUTTON_HOVER_DISABLED if SfxPlayer.mute else UI_SFX_BUTTON_HOVER
	sfx_button.texture_focused = UI_SFX_BUTTON_DISABLED if SfxPlayer.mute else UI_SFX_BUTTON
	
		
func music_button_state() -> void:
	music_button.visible = visible
	music_button.texture_normal = UI_MUSIC_BUTTON_DISABLED if MusicPlayer.mute else UI_MUSIC_BUTTON
	music_button.texture_hover = UI_MUSIC_BUTTON_HOVER_DISABLED if MusicPlayer.mute else UI_MUSIC_BUTTON_HOVER
	music_button.texture_pressed = UI_MUSIC_BUTTON_HOVER_DISABLED if MusicPlayer.mute else UI_MUSIC_BUTTON_HOVER
	music_button.texture_focused = UI_MUSIC_BUTTON_DISABLED if MusicPlayer.mute else UI_MUSIC_BUTTON
