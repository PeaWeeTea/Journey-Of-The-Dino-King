extends Node2D

var enemy_scene = preload("res://enemy.tscn")
@onready var enemy_spawn_active = false
@onready var spawn_timer = $SpawnTimer
# array of an array of spawn points divided between the 4 doorways: up, right, down, left
@onready var spawn_door_list = [
	get_tree().get_nodes_in_group("up_enemy_spawn_points"),
	get_tree().get_nodes_in_group("right_enemy_spawn_points"),
	get_tree().get_nodes_in_group("left_enemy_spawn_points"),
	get_tree().get_nodes_in_group("down_enemy_spawn_points")]
var difficulty_timer: float = 20.0 # time between difficulty increases

# Every time the spawnrate timer times out spawn an enemy on a random number of
# spawnpoints in the enemyspawnpoints group
func _process(delta):
	# Countdown the difficulty timer
	difficulty_timer -= delta
	
	# check if difficulty timer has ender and increase difficulty
	if difficulty_timer <= 0:
		increase_difficulty()
		difficulty_timer = 20.0 # Reset the difficulty timer

func _on_spawn_rate_timeout():
	var player = get_node("/root/World/Player")
	for spawn_door in spawn_door_list:
		for spawn_point in spawn_door:
			var spawn_position = spawn_point.global_position
			print("spawn point position: ", spawn_position)
			if player != null:
				var enemy = enemy_scene.instantiate()
				enemy.global_position = spawn_position
				print("enemy spawn position: ", enemy.global_position)
				get_parent().add_child(enemy)

func increase_difficulty():
	pass
