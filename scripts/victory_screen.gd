extends Control

const CLICK_SOUND = preload("res://assets/sfx/click.wav")

@onready var menu_button = $MainMenuButton

func _ready():
	get_tree().paused = false
	LevelTransition.fade_from_black()
	
	menu_button.grab_focus()


func _on_main_menu_button_pressed():
	AudioManager.play_sfx(CLICK_SOUND)
