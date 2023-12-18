extends CharacterBody2D
#layer = what they are
#mask = what they collide with
#skate race

@export var movement_data : PlayerMovementData
var airAction = true
var movementup = false
var newWallJump
var canMove = true
var facingLeft = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $"coyote jump timer"
@onready var startingPosition = global_position
func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	var was_on_floor = is_on_floor()
	
	# Add the gravity.
	apply_gravity(delta)
	
	handleJump(delta)
	dodge()
	handleWallJump()
	attack()
	if canMove == false:
		if animated_sprite_2d.get_frame() == 5:
				$Attacks.monitoring = true
	flip()
	
	#changes movement data
	
	#change to powerup?
	#if Input.is_action_just_pressed("ui_accept"):
	#	if movementup == false:
	#		movement_data=load("res://fasterMovementData.tres")
	#		movementup = true
	#	else:
	#		movement_data = load("res://DefaultMovementData .tres")
	#		movementup = false
	#movement
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#technically input_axis
	
	#handle acceleration
	movement(direction, delta)
	
	updateAnim(direction)
	applyAirResistance(direction, delta)
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	
	if just_left_ledge:
		coyote_jump_timer.start()

func movement(direction, delta):
	#handle acceleration
	if canMove == true:
		if direction:
			velocity.x = move_toward(velocity.x, movement_data.speed*direction, movement_data.acceleration*delta)
		else:
			#handle friction
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, movement_data.friction*delta)

func handleJump(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravityScale * delta
	if Input.is_action_just_released("jump") and velocity.y < movement_data.jumpVelocity/2:
			velocity.y = movement_data.jumpVelocity/2
	if canMove:
	# Handle Jump.
		if is_on_floor() or coyote_jump_timer.time_left > 0.00:
			if Input.is_action_just_pressed("jump"):
				velocity.y = movement_data.jumpVelocity
		#double jump
		if not is_on_floor() && coyote_jump_timer.timeout:
			if Input.is_action_just_pressed("jump") && airAction && $Health.stamina > 0:
				velocity.y = movement_data.jumpVelocity
				$Health.stamina -= 1
				airAction = false
	if is_on_floor():
		airAction = true
		newWallJump = movement_data.wallJumpSpeed

func dodge():
	if Input.is_action_just_pressed("dodge"):
		if$Health.stamina > 0:
			#make invincible
			$HazardDetector.set_collision_mask_value(3, false)
			canMove = false
			animated_sprite_2d.play("roll")
			if animated_sprite_2d.flip_h:
				velocity.x= move_toward(velocity.x, -movement_data.dodgeSpeed ,movement_data.dodgeSpeed)
			else:velocity.x= move_toward(velocity.x, movement_data.dodgeSpeed ,movement_data.dodgeSpeed)
			await get_tree().create_timer(.3).timeout
			#animated_sprite_2d.animation_finished
			velocity.x = 0
			$HazardDetector.set_collision_mask_value(3, true)
			canMove = true


func attack():
	if Input.is_action_just_pressed("attack"):
		#print("attack")
		if canMove == true && $Health.stamina > 0:
			canMove = false
			
			animated_sprite_2d.play("punch")
			
			if animated_sprite_2d.get_frame() == 5:
				$Attacks.monitoring = true
				
			await get_tree().create_timer(.3).timeout
			$Attacks.monitoring = false
			canMove = true

func handleWallJump():
	if !is_on_wall(): return
	if is_on_floor(): return
	
	var wallNormal = get_wall_normal()
	if !is_on_floor():
		if Input.is_action_just_pressed("ui_left") && wallNormal == Vector2.LEFT && $Health.stamina > 0:
			velocity.x = wallNormal.x * newWallJump
			velocity.y = movement_data.jumpVelocity
			newWallJump -= 50
			$Health.stamina-=1

		if Input.is_action_just_pressed("ui_right") && wallNormal == Vector2.RIGHT && $Health.stamina > 0:
			velocity.x = wallNormal.x * newWallJump
			velocity.y = movement_data.jumpVelocity
			newWallJump -= 50
			$Health.stamina-=1

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		

func updateAnim(input_axis):
	if(input_axis!=0) && canMove == true:
		animated_sprite_2d.flip_h = (input_axis < 0)
		
		
		animated_sprite_2d.play("run")
	else:
		if canMove == true:
			animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		if canMove == true:
			animated_sprite_2d.play("jump")
#slide at end of jump

func applyAirResistance(input_axis, delta):
	if input_axis==0 && !is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.airResistance * delta)

func _on_hazard_detector_area_entered(area): #on taking damage
	$Health.health -= 1
	global_position = startingPosition

func flip():
	if canMove:
		if Input.is_action_just_pressed("left"):
			if !facingLeft: $Attacks.position.x = $Attacks.position.x* -1
			facingLeft = true
		if Input.is_action_just_pressed("right"):
			if facingLeft: $Attacks.position.x = $Attacks.position.x * -1
			facingLeft = false




