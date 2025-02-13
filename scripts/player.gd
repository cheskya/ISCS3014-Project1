# I hereby attest to the truth of the following facts:
#
# I have not discussed the C++ code in my program with anyone
# other than my instructor or the teaching assistants assigned to this course.
# 
# I have not used C++ code obtained from another student, or
# any other unauthorized source, whether modified or unmodified.
#
# If any C++ code or documentation used in my program was
# obtained from another source, it has been clearly noted with citations in the
# comments of my program.

extends CharacterBody2D

@onready var ray = $RayCast2D
@onready var tilemap: TileMapLayer = get_parent().get_node("Map")
@export var tile_size = 32
@export var speed = 5
var moving = false
var forced = false
var just_teleported = false

var inputs = {"move_right": Vector2.RIGHT,
			"move_left": Vector2.LEFT,
			"move_up": Vector2.UP,
			"move_down": Vector2.DOWN}

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta):
	if moving:
		return
	
	var tile_id = get_tile_id(position)
	
	forced = false
	
	if tile_id == 3:  
		var forced_dir = get_wave_tile_direction(position)
		if forced_dir != Vector2.ZERO:
			await move_forced(forced_dir)
	
	if tile_id == 4:
		var whirl_pos = position
		teleport(whirl_pos)
	
	for dir in inputs.keys():
		if Input.is_action_pressed(dir) and forced == false:
			move(dir)
			just_teleported = false
	
	if !moving and !forced:
		$AnimatedSprite2D.animation = "idle"

func get_tile_id(pos: Vector2) -> int:
	if tilemap == null:
		print("Error: TileMap is null!")
		return -1  
	var tile_pos = tilemap.local_to_map(pos)  
	return tilemap.get_cell_source_id(tile_pos) 

func get_wave_tile_direction(pos: Vector2) -> Vector2:
	if tilemap == null:
		return Vector2.ZERO
	var tile_pos = tilemap.local_to_map(pos)
	var tile_data = tilemap.get_cell_tile_data(tile_pos)
	
	if tile_data:
		var direction = tile_data.get_custom_data("direction")
		if direction is Vector2:  # Ensure it's a valid Vector2
			return direction
	
	return Vector2.ZERO

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

func move_forced(direction: Vector2):
	if !moving:
		forced = true
		if direction.x < 0:
			$AnimatedSprite2D.animation = "moving_left"
		elif direction.x > 0:
			$AnimatedSprite2D.animation = "moving_right"
		elif direction.y < 0:
			$AnimatedSprite2D.animation = "moving_up"
		elif direction.y > 0:
			$AnimatedSprite2D.animation = "moving_down"
	await move_to(direction)

func teleport(whirl_pos: Vector2):
	if !just_teleported:
		var whirl1: Vector2 = Vector2(240, -164)
		var whirl2: Vector2 = Vector2(-240, 156)
		var target_position = null
		if whirl_pos == whirl1:
			target_position = whirl2
		else:
			target_position = whirl1 
		await teleport_to(target_position, whirl_pos)

func move_to(direction: Vector2):
	ray.target_position = direction * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + direction * tile_size, 1.0 / speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false
 
func teleport_to(target_pos: Vector2, previous_pos: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 1.0 / speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
	just_teleported = true
