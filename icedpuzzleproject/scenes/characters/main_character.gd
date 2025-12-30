extends CharacterBody2D

const TILESIZE = 16

@export var speed : float

@onready var ray = $RayCast2D
@onready var animatedSprite = $AnimatedSprite
@onready var tile_map = $"../TileMapLayer"

var currentState
var lastDirection := "down"
var isMoving := false

func _ready() -> void:
	currentState = "idle"

func _physics_process(_delta) -> void:
	get_inputs_movement()
	move_and_slide()
	update_animation()

func get_inputs_movement() -> void:
	var input_direction = Vector2.ZERO
	if velocity != Vector2.ZERO:
		isMoving = true
	else: 
		isMoving = false
		
	if isMoving: 
		return
		
	if Input.is_action_just_pressed("move_left"):
		input_direction = Vector2.LEFT
		lastDirection = "left"
	if Input.is_action_just_pressed("move_right"):
		input_direction = Vector2.RIGHT
		lastDirection = "right"
	if Input.is_action_just_pressed("move_down"):
		input_direction = Vector2.DOWN
		lastDirection = "down"
	if Input.is_action_just_pressed("move_up"):
		input_direction = Vector2.UP
		lastDirection = "up"
	
	move(input_direction)

func move(direction : Vector2) -> void:
	var currentTile : Vector2i = tile_map.local_to_map(global_position)
	var currentTileData : TileData = tile_map.get_cell_tile_data(currentTile)
	isMoving = true
	if direction == Vector2.ZERO:
		return
	update_raycast(direction)
	if currentTileData.has_custom_data("ice_walkable") == false:
		#velocity = speed*direction
		
		var myTween = create_tween()
		myTween.tween_property(self, "velocity", speed*direction, 0.2)

func update_raycast(direction : Vector2) -> void:
	ray.target_position = direction*TILESIZE

func update_animation() -> void:
	if velocity != Vector2.ZERO:
		currentState = "move"
	else:
		currentState = "idle"
	
	animatedSprite.play(currentState + "_" + lastDirection)
	
	
