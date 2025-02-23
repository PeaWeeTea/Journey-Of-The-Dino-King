extends CharacterBody2D

const DEATH_SOUND = preload("res://assets/sfx/enemyDeath.wav")

@export var health = 1

var one_coin_instance = preload("res://scenes/1_coin.tscn").instantiate()
var five_coin_instance = preload("res://scenes/5_coin.tscn").instantiate()
var heart_instance = preload("res://scenes/heart.tscn").instantiate()
@onready var player = get_node("../Player")
@onready var level_node = get_parent()

@export var speed = 40.0
@export var one_coin_drop_rate = 0.1
@export var five_coin_drop_rate = 0.05
@export var heart_drop_rate = 0.009

func _physics_process(delta):
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		#var wall_dir = get_wall_normal()
		## check if colliding with wall and the angle between the wall and player is less than 45 degrees
		#if is_on_wall() == true and (abs(wall_dir.angle_to(direction)) >= PI / 4):
			#print("Enemy angle: ", abs(wall_dir.angle_to(direction)))
			#var dir_vector = wall_dir
			#if not dir_vector.x == 0:
				## randimize 50/50 if y is -1 or 1
				#dir_vector.y = -1 * (-1 * randi_range(1, 2))
				#dir_vector.x = 0  # Set x to 0 so no diagonal movement
			#else:
				#dir_vector.x = -1 * (-1 * randi_range(1, 2))
				#dir_vector.y = 0
			#direction = dir_vector
		velocity = direction * speed
	move_and_slide()


func take_damage():
	health -= 1
	if health == 0:
		if try_rand_drop(heart_drop_rate) == true:
			# drop the heart
			heart_instance.global_position = global_position
			level_node.add_child(heart_instance)
		elif try_rand_drop(five_coin_drop_rate) == true:
			# drop the five coin
			five_coin_instance.global_position = global_position
			level_node.add_child(five_coin_instance)
		elif try_rand_drop(one_coin_drop_rate) == true:
			# drop the one coin
			one_coin_instance.global_position = global_position
			level_node.add_child(one_coin_instance)
		
		AudioManager.play_sfx(DEATH_SOUND)
		# defer the queue_free call to after the physics processes
		call_deferred("queue_free")

# returns true if a coin can drop and false if it cannot
func try_rand_drop(drop_rate) -> bool:
	# Generate a random float between 0 and 1
	var drop_chance = randf()
	
	# Check if the drop chance is <= the coin's drop rate
	if drop_chance <= drop_rate:
		return true
	else:
		return false
