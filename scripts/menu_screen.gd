extends Control

const CLICK_SOUND = preload("res://assets/sfx/click.wav")

@export var next_level: PackedScene


func _on_play_button_pressed():
	print("play button pressed")
	await AudioManager.play_sfx(CLICK_SOUND)
	go_to_next_level()


func _on_quit_button_pressed():
	print("quit button pressed")
	await AudioManager.play_sfx(CLICK_SOUND)
	get_tree().quit()


func go_to_next_level():
	get_tree().paused = true
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
