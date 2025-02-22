extends Area2D

const PICKUP_SOUND = preload("res://assets/sfx/pickupCoin.wav")

@export var coin_value: int
@export var first_despawn_blink_time = 10.0
@export var last_despawn_blink_time = 4.0

@onready var first_blink_timer = 0.5
@onready var last_blink_timer = 0.25

func _process(delta):
	try_despawn_blink(delta)

func _on_body_entered(body):
	if "player" in body.get_groups():
		PlayerVariables.coins += coin_value
		Events.coin_collected.emit()
		AudioManager.play_sfx(PICKUP_SOUND)
		queue_free()

func _on_despawn_timer_timeout():
	queue_free()

func try_despawn_blink(delta):
		# start blinking when coin is about to despawn
	var despawn_time_left = $DespawnTimer.time_left
	if despawn_time_left <= first_despawn_blink_time and despawn_time_left > last_despawn_blink_time:
		if first_blink_timer <= 0.0:
			visible = !visible
			first_blink_timer = 0.5
		first_blink_timer -= delta
	elif despawn_time_left <= last_despawn_blink_time:
		if last_blink_timer <= 0.0:
			visible = !visible
			last_blink_timer = 0.25
		last_blink_timer -= delta
