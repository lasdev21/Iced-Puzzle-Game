extends CharacterBody2D

const TILESIZE = 16

@export var speed : float

@onready var push_area = $Area2D
@onready var push_ray = $Area2D/CollisionShape2D
@onready var animatedSprite = $AnimatedSprite
@onready var waitTime = $Timer
@onready var tile_map = $"../TileMapLayer"

var currentState
var lastDirection := "down"
var lastDirection_vector := Vector2.ZERO
var isMoving := false
var hasCollided := false

func _ready() -> void:
	currentState = "idle"
	push_area.area_entered.connect(send_push.bind())
	push_ray.disabled = true

func _physics_process(_delta) -> void:
	if waitTime.is_stopped():
		push_ray.disabled = true
	get_inputs_movement()
	get_inputs_actions()
	
	if isMoving:
		move_and_slide()
		if is_on_wall():
			var wall_normal = get_wall_normal()
			if abs(lastDirection_vector.dot(wall_normal)) > 0.7:
				isMoving = false
				velocity = Vector2.ZERO
	else:
		if waitTime.is_stopped():
			velocity = Vector2.ZERO
	update_animation()

func get_inputs_movement() -> void:
	var input_direction = Vector2.ZERO
	#if velocity != Vector2.ZERO:
		#isMoving = true
	#if is_on_wall():
		#isMoving = false
		##if not hasCollided:
		#velocity = Vector2.ZERO
		#print(get_wall_normal())
		##	hasCollided = true
#
	if isMoving:
		#hasCollided = false
		return
		
	if Input.is_action_just_pressed("move_left"):
		input_direction = Vector2.LEFT
		lastDirection_vector = Vector2.LEFT
		lastDirection = "left"
	if Input.is_action_just_pressed("move_right"):
		input_direction = Vector2.RIGHT
		lastDirection_vector = Vector2.RIGHT
		lastDirection = "right"
	if Input.is_action_just_pressed("move_down"):
		input_direction = Vector2.DOWN
		lastDirection_vector = Vector2.DOWN
		lastDirection = "down"
	if Input.is_action_just_pressed("move_up"):
		input_direction = Vector2.UP
		lastDirection_vector = Vector2.UP
		lastDirection = "up"
	
	move(input_direction)

func get_inputs_actions() -> void:
	if isMoving:
		return
	
	if Input.is_action_just_pressed("action_push"):
		print("pushing")
		push_ray.disabled = false
		waitTime.start()
	#if not push_area.has_overlapping_bodies():
	#	return

func move(direction : Vector2) -> void:
	#var currentTile : Vector2i = tile_map.local_to_map(global_position)
	#var currentTileData : TileData = tile_map.get_cell_tile_data(currentTile)
	#isMoving = true
	if direction == Vector2.ZERO:
		return
	update_raycast(direction)
	isMoving = true
	
	var myTween = create_tween()
	myTween.tween_property(self, "velocity", speed*direction, 1.0)

func update_raycast(direction : Vector2) -> void:
	var ray_shape = push_ray.shape
	ray_shape.b = direction*TILESIZE

func update_animation() -> void:
	if velocity != Vector2.ZERO:
		currentState = "move"
	else:
		currentState = "idle"
	
	animatedSprite.play(currentState + "_" + lastDirection)

func send_push(area: Area2D) -> void:
	if not area.has_signal("direction_to_go"):
		return
	area.direction_to_go.emit(lastDirection_vector)
