
extends CharacterBody2D

@onready var ray = $RayCast2D
@onready var tilemap: TileMapLayer = get_parent().get_node("Map")
@export var tile_size = 32
@export var speed = 5
var moving = false
var forced = false

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
	print("Tile ID at current position:", tile_id)

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
	await move_to(position + direction * tile_size)
	
func teleport(whirl_pos: Vector2):
	var whirl1: Vector2 = Vector2(240, -164)
	var whirl2: Vector2 = Vector2(-240, 156)
	var target_position = null
	if whirl_pos == whirl1:
		target_position = whirl2
	else:
		target_position = whirl1 
	await move_to(target_position)
	
func move_to(target_pos: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 1.0 / speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
