extends Box
class_name PhysicsBox

@export var speed : float
@onready var pushed_reciever = $Area2D

func _ready() -> void:
	pushed_reciever.direction_to_go.connect(pushed.bind())
	
func _physics_process(_delta: float) -> void:
	move_and_slide()
	#print()

func pushed(direction : Vector2) -> void:
	var myTween = create_tween()
	myTween.tween_property(self, "velocity", speed*direction, 0.2)
