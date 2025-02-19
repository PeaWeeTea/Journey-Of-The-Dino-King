extends CharacterBody2D

@export var health = 1

@export var one_coin_instance = preload("res://scenes/1_coin.tscn").instantiate()
@export var five_coin_instance = preload("res://scenes/5_coin.tscn").instantiate()
@onready var player = get_node("/root/World/Player")
@onready var level_node = get_parent()

@export var speed = 40.0
@export var one_coin_drop_rate = 0.1
@export var five_coin_drop_rate = 0.05

func _physics_process(delta):
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
	move_and_slide()


func take_damage():
	health -= 1
	if health == 0:
		if try_coin_drop(five_coin_drop_rate) == true:
			# drop the five coin
			five_coin_instance.global_position = global_position
			level_node.add_child(five_coin_instance)
		elif try_coin_drop(one_coin_drop_rate) == true:
			# drop the one coin
			one_coin_instance.global_position = global_position
			level_node.add_child(one_coin_instance)
		# defer the queue_free call to after the physics processes
		call_deferred("queue_free")

# returns true if a coin can drop and false if it cannot
func try_coin_drop(drop_rate) -> bool:
	# Generate a random float between 0 and 1
	var drop_chance = randf()
	
	# Check if the drop chance is <= the coin's drop rate
	if drop_chance <= drop_rate:
		return true
	else:
		return false
