extends CharacterBody2D

@onready var ray = $RayCast2D
@export var tile_size = 32
@export var speed = 5
var moving = false

var inputs = {"move_right": Vector2.RIGHT,
			"move_left": Vector2.LEFT,
			"move_up": Vector2.UP,
			"move_down": Vector2.DOWN}

func _physics_process(delta):
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			move(dir)
	
	if moving:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

func move(dir):
	if !moving:
		if inputs[dir].x < 0:
			$AnimatedSprite2D.animation = "moving_left"
		elif inputs[dir].x > 0:
			$AnimatedSprite2D.animation = "moving_right"
		elif inputs[dir].y < 0:
			$AnimatedSprite2D.animation = "moving_up"
		elif inputs[dir].y > 0:
			$AnimatedSprite2D.animation = "moving_down"
		ray.target_position = inputs[dir] * tile_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", (position + inputs[dir] * tile_size), 1.0/speed).set_trans(Tween.TRANS_SINE)
			moving = true
			await tween.finished
			moving = false
