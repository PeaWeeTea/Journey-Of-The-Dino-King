extends CharacterBody2D

const DEATH_SOUND = preload("res://assets/sfx/playerDeath.wav")

@export var speed = 100.0
@export var respawn_time = 3

func _physics_process(delta):
	var direction = Vector2(Input.get_axis("move_left", "move_right"),
	Input.get_axis("move_up", "move_down"))
	velocity = direction.normalized() * speed
	move_and_slide()
	
	if direction.x > 0:
		%PlayerSprite.play("move_right")
	elif direction.x < 0:
		%PlayerSprite.play("move_left")
	
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		PlayerVariables.lives -= 1
		if PlayerVariables.lives <= 0:
			Events.player_lives_depleted.emit()
			AudioManager.play_sfx(DEATH_SOUND)
			self.hide()
		else:
			Events.player_life_lost.emit(PlayerVariables.lives, respawn_time)
			AudioManager.play_sfx(DEATH_SOUND)
			self.hide()


