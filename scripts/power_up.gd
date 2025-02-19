extends Area2D

# despawn variables
@export var first_despawn_blink_time = 10.0
@export var last_despawn_blink_time = 4.0
@onready var first_blink_timer = 0.5
@onready var last_blink_timer = 0.25

@export var drop_chance: float

# Define powerup states
enum State {
	DROPPED,
	PICKED_UP,
	ACTIVATED
}

# current state variable
var current_state : State = State.DROPPED

# signals
signal picked_up(power_up: String)
signal activated(power_up: String)

# Function that will only process if state is DROPPED
func _process(delta):
	if current_state == State.DROPPED:
		# Only execute this logic if the state is DROPPED
		try_despawn_blink(delta)

# Function that can be overridden by specific power-ups to apply effects
func apply_effects(player: Node, gun: Node, enemies: Array) -> void:
	# This can be overridden in child classes to apply specific effects
	pass

# Function to handle transitions to "PICKED_UP" state
func _on_picked_up():
	if current_state == State.DROPPED:
		current_state = State.PICKED_UP
		print("State changed to: ", get_state_name(current_state))
		emit_signal("picked_up")  # Emit a signal if needed

# Function to handle transitions to "ACTIVATED" state
func _on_activated():
	if current_state == State.PICKED_UP:
		current_state = State.ACTIVATED
		print("State changed to: ", get_state_name(current_state))
		emit_signal("activated")  # Emit a signal if needed

# Utility function to convert state enum to string (for easier debugging/logging)
func get_state_name(state: State) -> String:
	match state:
		State.DROPPED: return "DROPPED"
		State.PICKED_UP: return "PICKED_UP"
		State.ACTIVATED: return "ACTIVATED"
		_: return "UNKOWN" # _: is a catch all for match statements


func _on_despawn_timer_timeout():
	if current_state == State.DROPPED:
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


func _on_activated_duration_timer_timeout():
	# undo the changes the powerup made
	
	
	queue_free()
