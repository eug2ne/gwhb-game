extends Node
class_name MovementController

@export var parent: PlayableCharacter
@export var anim: AnimationPlayer
@onready var sprite: AnimatedSprite2D = parent.get_node("AnimatedSprite2D")

var direction: Vector2
var SPEED: float
@onready var IDLE_SPEED: float = parent.character_resource.idle_speed
@onready var DEFAULT_SPEED: float = parent.character_resource.move_speed
@onready var DASH_SPEED: float = parent.character_resource.dash_speed

func _ready():
	# set speed to default_speed
	SPEED = DEFAULT_SPEED

func _handle_input(event) -> void:
	if !parent.current:
		return
	if event.is_action_pressed("switch_pc"):
		# reset direction
		direction = Vector2(0,0)
		return
	
	# handle input event
	var directionX = Input.get_axis("move_left", "move_right")
	var directionY = Input.get_axis("move_up", "move_down")
	direction = Vector2(directionX, directionY).normalized()

func _handle_physics(_delta) -> void:
	parent.velocity = direction * SPEED
	parent.move_and_slide()

func _handle_process(_delta) -> void:
	# FIXME: when player take damage, damage animation interrupted by movement animation
		## need to play both animations at the same time
	# handle parent animation
	if SPEED == DEFAULT_SPEED && abs(parent.velocity) > Vector2(0,0):
		anim.play("move")
	else:
		anim.play("idle")
	# flip sprite according to parent.velocity
	if parent.velocity.x < 0:
		sprite.flip_h = true
	elif parent.velocity.x > 0:
		sprite.flip_h = false
