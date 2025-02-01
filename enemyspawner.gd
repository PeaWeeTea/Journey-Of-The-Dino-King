extends Node2D

var enemy_scene = preload("res://enemy.tscn")
@onready var enemy_spawn_active = false
@onready var spawn_timer = $SpawnTimer
var difficulty_timer: float = 20.0 # time between difficulty increases
var enemy_spawn_amount_per_door = 3
var difficulty_level = 0
# dict of arrays of spawn points divided between the 4 doorways: up, right, down, left
@onready var spawn_door_dict = {
	"up" : get_tree().get_nodes_in_group("up_enemy_spawn_points"),
	"right" : get_tree().get_nodes_in_group("right_enemy_spawn_points"),
	"down" : get_tree().get_nodes_in_group("down_enemy_spawn_points"),
	"left" : get_tree().get_nodes_in_group("left_enemy_spawn_points")}
# dictionary of spawn doors (key) and number of enemies in the spawn queue (value)
@onready var spawn_queue_dict = {
	"up" : 0,
	"right" : 0,
	"down" : 0,
	"left" : 0 }

func _ready():
	pass

func _physics_process(delta):
	# if difficulty level is 0 then return over and stop spawn timer
	if difficulty_level == 0:
		if not spawn_timer.is_stopped():
			spawn_timer.stop()
		return
	# turn on spawn timer if it is off
	if spawn_timer.is_stopped():
		spawn_timer.start()
	# if there are enemies in the spawn queue they will spawn first
	spawn_enemies_in_spawn_queue()
	# Countdown the difficulty timer
	difficulty_timer -= delta
	
	# check if difficulty timer has ender and increase difficulty
	if difficulty_timer <= 0:
		increase_difficulty()
		difficulty_timer = 20.0 # Reset the difficulty timer

# Every time the spawnrate timer times out spawn an enemy on a random number of
# spawnpoints in the enemyspawnpoints group
func _on_spawn_rate_timeout():
	# if difficulty level is 0 then return
	if difficulty_level == 0:
		return
	
	# Randomly choose new wait time on the spawn timer
	randomize_wait_time(difficulty_level)
	# Randomly choose how many enemies to spawn
	var enemy_amount_to_spawn: int = get_random_amount_of_enemies()
	# Randomly choose which doorways to spawn enemies and
	# how many enemies to spawn in each doorway
	var enemies_to_spawn_dict = get_enemies_to_spawn(enemy_amount_to_spawn)
	# add the enemies_to_spawn to the spawn_queue
	for direction in enemies_to_spawn_dict.keys():
		spawn_queue_dict[direction] += enemies_to_spawn_dict[direction]
	
	#var player = get_node("/root/World/Player")
	#for spawn_door in spawn_door_dict.values():
		## if this spawn door is blocked then continue iterating 
		## to the next spawn door
		#if has_blocked_spawn_door(spawn_door):
			#continue
		#for spawn_point in spawn_door:
			## spawn an enemy
			#var spawn_position = spawn_point.global_position
			#if player != null:
				#spawn_enemy(enemy_scene, spawn_position)


func increase_difficulty():
	pass

# spawns all the enemies in each doorway if there are any in the queue and
# the doorway is clear of enemies
func spawn_enemies_in_spawn_queue():
	var player = get_node("/root/World/Player")
	# iterated through each direction in the spawn_queue_dict
	for direction in spawn_queue_dict.keys():
		if spawn_queue_dict[direction] > 0:
			# if the spawn detector on the [direction] doorway has any bodies on the
			# enemy layer that does not overlap then spawn upwards of three enemies
			if not has_blocked_spawn_door(direction):
				for i in range(spawn_queue_dict[direction]):
					# if it spawned 3 enemies or the spawn queue emptied, stop
					if i >= 3 or spawn_queue_dict[direction] <= 0:
						break
					# get the ith spawn point position in the array in the dictionary
					var spawn_point = spawn_door_dict[direction][i].global_position
					if player != null:
						spawn_enemy(enemy_scene, spawn_point)
						spawn_queue_dict[direction] -= 1

func spawn_enemy(enemy_scene, spawn_position):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	get_parent().add_child(enemy)

# checks if one specific spawn door is blocked
# spawn_door being an array of spawn points
func has_blocked_spawn_door(spawn_door_direction) -> bool:
		# check if spawn locations already have enemies there and if 
		# they do add the enemies we were trying to spawn to the spawn queue
		#var spawn_door_direction = spawn_door_dict.find_key(spawn_door)
		if spawn_door_direction == "up" and $UpSpawnDoorDetector.has_overlapping_bodies():
			#spawn_queue_dict["up"] += enemy_spawn_amount_per_door
			return true
		elif spawn_door_direction == "right" and $RightSpawnDoorDetector2.has_overlapping_bodies():
			#spawn_queue_dict["right"] += enemy_spawn_amount_per_door
			return true
		elif spawn_door_direction == "down" and $DownSpawnDoorDetector3.has_overlapping_bodies():
			#spawn_queue_dict["down"] += enemy_spawn_amount_per_door
			return true
		elif spawn_door_direction == "left" and $LeftSpawnDoorDetector4.has_overlapping_bodies():
			#spawn_queue_dict["left"] += enemy_spawn_amount_per_door
			return true
		else:
			return false

# return dict of strings(keys): "up" "right" "down" or "left"
# and number of enemies to spawn through each door(values)
# then just add these values to the spawn_queue dict
func get_enemies_to_spawn(number_of_enemies_to_spawn: int):
	var selected_enemies_to_spawn_dict = {}
	var num_doorways = randi_range(4, 4)
	var chosen_indices = []
	var doorways = spawn_door_dict.keys()

	# Populate the enemies to spawn dict with random doorways and 0 enemies
	while chosen_indices.size() < num_doorways:
		var index = randi_range(0, 3)
		if index not in chosen_indices:
			chosen_indices.append(index)
			selected_enemies_to_spawn_dict[doorways[index]] = 0
	
	# add a random number between 0 and 7 for each doorway until
	# the num of enemies to spawn is 0
	var MAX_NUM_SPAWN = 4
	var i = 0
	var selected_doorways = selected_enemies_to_spawn_dict.keys()
	while number_of_enemies_to_spawn > 0:
		if number_of_enemies_to_spawn < MAX_NUM_SPAWN:
			MAX_NUM_SPAWN = number_of_enemies_to_spawn
		var iterated_doorway = selected_doorways[i % selected_doorways.size()]
		var rand_num = randi_range(0, MAX_NUM_SPAWN)
		selected_enemies_to_spawn_dict[iterated_doorway] += rand_num
		number_of_enemies_to_spawn -= rand_num
		i += 1
	
	return selected_enemies_to_spawn_dict


func get_random_amount_of_enemies(): # return an int
	return randi_range(1, 6) # temp return rand num between 6 and 18

func randomize_wait_time(level_of_difficulty):
	# stop the timer and then set the random time so timer doesn't start
	# counting down again before setting the new wait time
	spawn_timer.stop()
	$SpawnTimer.wait_time = randf_range(1.0, 2.0)
	spawn_timer.start()

# set the difficulty level to zero when the level ends
func _on_level_timer_timeout():
	difficulty_level = 0
