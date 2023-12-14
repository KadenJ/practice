extends CharacterBody2D


@export var SPEED = 150.0
@export var ACCELERATION = 600
@export var FRICTION = 800
@export var JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $"coyote jump timer"


func _physics_process(delta):
	# Add the gravity.
	apply_gravity(delta)
	
	handleJump(delta)
	

	#movement
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#technically input_axis
	var direction = Input.get_axis("ui_left", "ui_right")
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	
	if just_left_ledge:
		coyote_jump_timer.start()
		
	#handle acceleration
	if direction:
		velocity.x = move_toward(velocity.x, SPEED*direction, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION*delta)
	updateAnim(direction)
	
	
	
func handleJump(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if is_on_floor() or coyote_jump_timer.time_left > 0.00:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
	if not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < JUMP_VELOCITY/2:
			velocity.y = JUMP_VELOCITY/2
	
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		

func updateAnim(input_axis):
	if(input_axis!=0):
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")
		
