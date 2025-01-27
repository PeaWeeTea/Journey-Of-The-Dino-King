extends Area2D

@export var coin_value: int

func _on_body_entered(body):
	if "player" in body.get_groups():
		PlayerVariables.coins += coin_value
		Events.coin_collected.emit()
		queue_free()
