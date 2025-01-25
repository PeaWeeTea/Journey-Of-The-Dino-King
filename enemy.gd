extends CharacterBody2D

var health = 1

@onready var player = get_node("/root/World/Player")

@export var speed = 40.0

func _physics_process(delta):
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
	move_and_slide()


func take_damage():
	health -= 1
	
	if health == 0:
		queue_free()
