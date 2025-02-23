extends Node2D

@export var next_level : PackedScene

var PLAYER_SCENE = preload("res://scenes/player.tscn")
@onready var player = $Player

@onready var enemy_spawner = $EnemySpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	if not next_level is PackedScene:
		#level_completed_gui.next_level_button.text = "Victory Screen"
		next_level = load("res://scenes/victory_screen.tscn")
	Events.level_completed.connect(show_level_completed)
	Events.player_life_lost.connect(_on_player_life_lost)
	Events.player_lives_depleted.connect(_on_player_lives_depleted)
	Events.coin_collected.connect(_on_coin_collected)
	Events.heart_collected.connect(_on_heart_collected)
	LevelTransition.fade_from_black()
	
	%Coins.text = "x" + str(PlayerVariables.coins)
	%Lives.text = "x" + str(PlayerVariables.lives)
	player = get_tree().get_first_node_in_group("player")
	assert(player!=null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	# If the level timer is running down update the level timer bar ui
	var level_time_left = $LevelTimer.time_left
	# Controls the difficulty of the level based on level timer
	if not $LevelTimer.is_stopped():
		$GUI/LevelTimeBar.value = level_time_left

func _on_coin_collected():
	%Coins.text = "x" + str(PlayerVariables.coins)


func _on_heart_collected():
	%Lives.text = "x" + str(PlayerVariables.lives)


func _on_player_life_lost(current_lives, respawn_time):
	delete_enemies()
	delete_pickupable_objects()
	
	%Lives.text = "x" + str(current_lives)
	get_tree().paused = true
	await get_tree().create_timer(respawn_time).timeout
	get_tree().paused = false
	spawn_player(%PlayerSpawn.global_position)


func _on_player_lives_depleted():
	PlayerVariables.lives = 3
	PlayerVariables.coins = 0
	player.queue_free()
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func spawn_player(spawn_point):
	player.global_position = spawn_point
	player.visible = true

func _on_start_delay_timer_timeout():
	$LevelTimer.start()
	enemy_spawner.difficulty_level = 1

func show_level_completed():
	pass


func go_to_level(level: PackedScene):
	get_tree().paused = true
	if not level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(level)


func _on_level_timer_timeout():
	$TileMapContainer/LevelFinishedTileMap.visible = true
	$InvisibleWalls/DownWall.disabled = true
	
	# enable the bullet barrier around the level
	$InvisibleWalls/BulletWalls/RightBoundary.disabled = false
	$InvisibleWalls/BulletWalls/UpBoundary.disabled = false
	$InvisibleWalls/BulletWalls/LeftBoundary.disabled = false
	
	delete_enemies()
	$GUI/ArrowIcon/BlinkTimer.start()
	$GUI/ArrowIcon.visible = true

func _on_level_complete_trigger_body_entered(body):
	print("Player triggered level complete")
	go_to_level(next_level)


func delete_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()


func delete_pickupable_objects():
	var pickupable_objects = get_tree().get_nodes_in_group("pickupable_objects")
	for object in pickupable_objects:
		object.queue_free()
