extends TextureRect


func _on_blink_timer_timeout():
	visible = !visible
