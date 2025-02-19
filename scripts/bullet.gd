extends Area2D

@onready var sprite = $Projectile

var travelled_distance = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	const SPEED = 200
	const RANGE = 500
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance >= RANGE:
		queue_free()


func _on_body_entered(body):
	# If bullet enters body with an environment collision layer, queue free
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()

func _process(delta):
	sprite.rotation = -rotation
