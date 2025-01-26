extends Node2D

var enemy_scene = preload("res://enemy.tscn")
@onready var spawn_rate = $SpawnRate
@onready var spawn_point_list = get_tree().get_nodes_in_group("enemyspawnpoints")

# Every time the spawnrate timer times out spawn an enemy on a random number of
# spawnpoints in the enemyspawnpoints group



func _on_spawn_rate_timeout():
	var player = get_node("/root/World/Player")
	for spawn_point in spawn_point_list:
		if player != null:
			var enemy = enemy_scene.instantiate()
			spawn_point.add_child(enemy)
		
