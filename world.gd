extends Node2D

@onready var PLAYER_SCENE = preload("res://player.tscn")
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerVariables.lives = 3
	player = get_tree().get_first_node_in_group("player")
	assert(player!=null)
	
	Events.player_life_lost.connect(_on_player_life_lost)
	Events.player_lives_depleted.connect(_on_player_lives_depleted)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	# If the level timer is running down update the level timer bar ui
	if !$LevelTimer.is_stopped():
		$GUI/LevelTimeBar.value = $LevelTimer.time_left


func _on_player_life_lost(current_lives, respawn_time):
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	
	%Lives.text = "x" + str(current_lives)
	get_tree().paused = true
	await get_tree().create_timer(respawn_time).timeout
	get_tree().paused = false
	spawn_player(%PlayerSpawn.global_position)


func _on_player_lives_depleted():
	get_tree().reload_current_scene()

func spawn_player(spawn_point):
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = spawn_point


func _on_start_delay_timer_timeout():
	$LevelTimer.start()
