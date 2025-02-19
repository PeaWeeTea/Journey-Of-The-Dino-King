extends Node2D

var cooldown_ready = true
const BULLET_SPAWN_DISTANCE = 15
@export var bullet_coyote_frames = 4
@onready var bullet_frame_count = 0
@onready var bullet_frame_list = []

# powerups active
var pu_rapid_fire_active = false
var pu_wheel_active = false


func _physics_process(delta):
	var bullet_direction = Vector2(float(Input.get_axis("shoot_left", "shoot_right")), 
		float(Input.get_axis("shoot_up", "shoot_down")))
	
	# if player shot and shot cooldown is finished then shoot
	if bullet_direction and cooldown_ready and check_coyote_ready(bullet_direction):
		var bullet_spawn_point = get_bullet_spawn_point(bullet_direction)
		
		shoot(bullet_spawn_point)



func shoot(bullet_spawn):
	const BULLET_SCENE = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET_SCENE.instantiate()
	
	new_bullet.global_position = bullet_spawn.global_position
	new_bullet.global_rotation = bullet_spawn.global_rotation
	bullet_spawn.add_child(new_bullet)
	$ShotCooldown.start()
	cooldown_ready = false

func _on_shot_cooldown_timeout():
	cooldown_ready = true
	$ShotCooldown.stop()

func check_coyote_ready(bullet_direction: Vector2) -> bool:
	# every process frame if there is shooting input, check past 3 frames if bullet_direction
	# is the same, effectively giving coyote time for bullets
	if (bullet_frame_count < bullet_coyote_frames and bullet_direction != Vector2.ZERO):
		for vector in bullet_frame_list:
			if vector != bullet_direction:
				bullet_frame_list.clear()
				bullet_frame_count = 0
				return false
		# appends the bullet_direction to the list if it is the first value
		# in the list or the same as the other items in the list
		bullet_frame_list.append(bullet_direction)
		bullet_frame_count += 1
	if bullet_frame_count >= bullet_coyote_frames:
		bullet_frame_list.clear()
		bullet_frame_count = 0
		return true
	else:
		return false

func get_bullet_spawn_point(bullet_direction: Vector2):
	if bullet_direction.x < 0 and bullet_direction.y < 0: # check if the direction is left and up
		return %UpLeftBulletSpawn
	elif bullet_direction.x < 0 and bullet_direction.y > 0: # check left and down
		return %DownLeftBulletSpawn
	elif bullet_direction.x > 0 and bullet_direction.y < 0: # check right and up
		return %UpRightBulletSpawn
	elif bullet_direction.x > 0 and bullet_direction.y > 0: # check right and down
		return %DownRightBulletSpawn
	elif bullet_direction.x < 0: # check if the direction is left
		return %LeftBulletSpawn
	elif bullet_direction.x > 0: # check right
		return %RightBulletSpawn
	elif bullet_direction.y < 0: # check up
		return %UpBulletSpawn
	elif bullet_direction.y > 0: # check down
		return %DownBulletSpawn

