extends Control

func _ready():
	get_tree().paused = false
	LevelTransition.fade_from_black()
	
	$MainMenuButton.grab_focus()
