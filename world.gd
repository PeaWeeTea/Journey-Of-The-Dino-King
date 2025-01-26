extends Node2D

@onready var PLAYER_SCENE = preload("res://player.tscn")
var death_timer = Timer.new()
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	death_timer.wait_time = 3
	death_timer.one_shot = true
	death_timer.autostart = false
	add_child(death_timer)
	death_timer.connect("timeout", _on_death_timer_timeout)
	
	player = get_tree().get_first_node_in_group("player")
	assert(player!=null)
	
	player.life_lost.connect(_on_life_lost)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	# If the level timer is running down update the level timer ber ui
	if !$LevelTimer.is_stopped():
		$GUI/LevelTimeBar.value = $LevelTimer.time_left
	print($LevelTimer.time_left)


func _on_life_lost(current_lives):
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	
	%Lives.text = "x" + str(current_lives)
	death_timer.start()


func _on_death_timer_timeout():
	death_timer.queue_free()
	spawn_player(%PlayerSpawn.global_position)
	


func spawn_player(spawn_point):
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = spawn_point


func _on_start_delay_timer_timeout():
	$LevelTimer.start()
