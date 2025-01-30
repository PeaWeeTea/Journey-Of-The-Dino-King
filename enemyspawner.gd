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
	"up" : 4,
	"right" : 4,
	"down" : 4,
	"left" : 4 }

func _ready():
	# randomize the spawn timer on ready
	randomize_timer(difficulty_level)
# Every time the spawnrate timer times out spawn an enemy on a random number of
# spawnpoints in the enemyspawnpoints group
func _physics_process(delta):
	# if there are enemies in the spawn queue they will spawn first
	spawn_enemies_in_spawn_queue()
	# Countdown the difficulty timer
	difficulty_timer -= delta
	
	# check if difficulty timer has ender and increase difficulty
	if difficulty_timer <= 0:
		increase_difficulty()
		difficulty_timer = 20.0 # Reset the difficulty timer

func _on_spawn_rate_timeout():
	# Randomly choose which doorways to spawn enemies
	
	# Randomly choose how many enemies to spawn
	
	# Randomly choose the wait time on the spawn timer
	randomize_timer(difficulty_level)
	
	var player = get_node("/root/World/Player")
	for spawn_door in spawn_door_dict.values():
		# if this spawn door is blocked then continue iterating 
		# to the next spawn door
		if has_blocked_spawn_door(spawn_door):
			continue
		for spawn_point in spawn_door:
			# spawn an enemy
			var spawn_position = spawn_point.global_position
			if player != null:
				spawn_enemy(enemy_scene, spawn_position)


func increase_difficulty():
	pass

# spawns all the enemies in each doorway if there are any in the queue and
# the doorway is clear of enemies
func spawn_enemies_in_spawn_queue():
	# iterated through each direction in the spawn_queue_dict
	for direction in spawn_queue_dict.keys():
		if spawn_queue_dict[direction] > 0:
			# if the spawn detector on the top doorway has any bodies on the
			# enemy layer that does not overlap then spawn upwards of three enemies
			if not $UpSpawnDoorDetector.has_overlapping_bodies():
				for i in range(spawn_queue_dict[direction]):
					# if it spawned 3 enemies or the spawn queue emptied, stop
					if i >= 3 or spawn_queue_dict[direction] <= 0:
						break
					# get the ith spawn point position in the array in the dictionary
					var spawn_point = spawn_door_dict[direction][i].global_position
					spawn_enemy(enemy_scene, spawn_point)
					spawn_queue_dict[direction] -= 1

func spawn_enemy(enemy_scene, spawn_position):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	get_parent().add_child(enemy)

# checks if one specific spawn door is blocked
# spawn_door being an array of spawn points
func has_blocked_spawn_door(spawn_door) -> bool:
		# check if spawn locations already have enemies there and if 
		# they do add the enemies we were trying to spawn to the spawn queue
		var spawn_door_direction = spawn_door_dict.find_key(spawn_door)
		if spawn_door_direction == "up" and $UpSpawnDoorDetector.has_overlapping_bodies():
			spawn_queue_dict["up"] += enemy_spawn_amount_per_door
			return true
		elif spawn_door_direction == "right" and $RightSpawnDoorDetector2.has_overlapping_bodies():
			spawn_queue_dict["right"] += enemy_spawn_amount_per_door
			return true
		elif spawn_door_direction == "down" and $DownSpawnDoorDetector3.has_overlapping_bodies():
			spawn_queue_dict["down"] += enemy_spawn_amount_per_door
			return true
		elif spawn_door_direction == "left" and $LeftSpawnDoorDetector4.has_overlapping_bodies():
			spawn_queue_dict["left"] += enemy_spawn_amount_per_door
			return true
		else:
			return false

func get_random_doorways():
	pass

func randomize_timer(level_of_difficulty):
	$SpawnTimer.wait_time = randi_range(4, 8)
