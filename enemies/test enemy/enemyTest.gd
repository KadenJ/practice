extends CharacterBody2D

#states
enum States{Move, CloseAttack, FarAttack, JumpAttack, Dead}
var currentState = States.Move
var playerPos 
var targetPos
var targetDist

#cooldown var
@onready var timer = $CloseAttackDetection/CoolDown
var cooldown : float
var coolingDown = false

#enemy movement
const SPEED = 300
const FAR_ATTACK_RANGE = 70

# Called when the node enters the scene tree for the first time.
func _ready():
	coolingDown = true
	cooldown = 3
	#animation_tree.active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#uses raycast to find player position relative to enemy, use it to flip sprite
	var space_state = get_world_2d().direct_space_state
	var player_group = get_tree().get_nodes_in_group("player")
	#boss is only active when player is created
	if player_group.size()>0:
		var playerPosition = player_group[0].position
		var query = PhysicsRayQueryParameters2D.create(self.position,playerPosition,2)
		var result = space_state.intersect_ray(query)
		if result:
			playerPos = to_local(result.position)
		else: print ("null result")
	
		#attacks called through match case
		match currentState:
			States.Move:
				$AnimationPlayer.play("move")
				Move(delta)
			States.CloseAttack:
				if cooldown <=0:
					canTurn = false
					CloseAttack()
				else: changeState(States.Move)
			States.FarAttack:
				canTurn = false
				targetDist = sqrt((playerPosition.x - position.x)**2)
				if targetDist > 24:
					FarAttackCharge()
				else:
					print("arrived")
					velocity.x = 0
					$AnimationPlayer.play("farAttack")
					
			States.Dead:
				velocity.x = 0
				$AnimationPlayer.play("Dead")
			
	else:
		# Handle the case where there are no nodes in the "player" group
		print("No player node found in the 'player' group.")
	
	coolDownCheck()
	FarAttackCheck()
	flip()
	handleGravity(delta)
	move_and_slide()
	

func coolDownCheck():
	if cooldown >0:
		timer.set_wait_time(cooldown)
		if coolingDown == true:
			timer.start()
			coolingDown = false
		

#should use targetDist to detect for closeAttack
func _on_player_detection_body_entered(_body): #detects player to start up attack
	#stop movement
	velocity.x = 0
	if currentState == States.Move:
		changeState(States.CloseAttack)

func changeState(newState):
	currentState = newState
	#print("state = %s" %currentState)

func attackBox(boxChild, endFrame):
	$hazardArea.get_child(boxChild).disabled = false
	#$hazardArea/CloseAttack.disabled = false
	$hazardArea.set_deferred("monitorable", true)
	#change to wait for certain frame  of animation
	
	await get_tree().create_timer(endFrame).timeout
	#change boxTimeActivate with in that represents frame count
	
	$hazardArea.set_deferred("monitorable", false)
	$hazardArea.get_child(boxChild).disabled = true

func CloseAttack():
	$AnimationPlayer.play("closeAttack")


func FarAttackCheck():
	if currentState == States.Move && cooldown<=0:
		if sqrt((playerPos.x **2)+(playerPos.y**2)) >= FAR_ATTACK_RANGE:#measures raycast distance to player
			targetPos = playerPos 
			changeState(States.FarAttack)
			return targetPos
			#print(to_global(targetPos))


func FarAttackCharge():
	
	# d = √((x2-x1)2 + (y2-y1)2)
	#move toward player
	if targetPos.x < 0:
		velocity.x = move_toward(velocity.x,  targetPos.x, 500)
	elif targetPos.x > 0: 
		velocity.x = move_toward(velocity.x, targetPos.x, 500)
	
	#if round(targetDist) <= 24:
		##print("arrived")
		#velocity.x = 0
		#$AnimationPlayer.play("farAttack")
		#cooldown = 2
		#coolingDown = true
		#changeState(States.Move)
	else:
		await get_tree().create_timer(3).timeout
		cooldown = 5
		coolingDown = true
		changeState(States.Move)
	

var isDone = false
func Move(delta):
	velocity.x = move_toward(velocity.x, SPEED*delta , 800)
	if isDone == false:
		isDone = true
		await get_tree().create_timer(1).timeout
		#print("walk")
		isDone = false
	


func handleGravity(delta):
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
#cooldown timer
func _on_timer_timeout():
	cooldown = 0 
	print("can attack")
#handle flipping character
var isLeft = true
var canTurn = true
func flip():
	if playerPos:
		if playerPos.x < 0:
			#$AnimatedSprite2D.flip_h = (playerPos.x<0)
			if !isLeft:
<<<<<<< Updated upstream:enemyTest.gd
				$AnimatedSprite2D.flip_h = !isLeft
				$hazardArea/CloseAttack.position = $hazardArea/CloseAttack.position * -1
				$CloseAttackDetection.scale = $CloseAttackDetection.scale * -1
				isLeft = true
		if playerPos.x>0:
			if isLeft:
				$AnimatedSprite2D.flip_h = !isLeft
				$hazardArea/CloseAttack.position = $hazardArea/CloseAttack.position * -1
				$CloseAttackDetection.scale = $CloseAttackDetection.scale * -1
				isLeft = false
=======
				if canTurn == true:
					$AnimatedSprite2D.flip_h = !isLeft
					$hazardArea/CloseAttack.position = $hazardArea/CloseAttack.position * -1
					$hazardArea/jabAttack.position = $hazardArea/jabAttack.position* -1
					$CloseAttackDetection.scale = $CloseAttackDetection.scale * -1
					isLeft = true
		if playerPos.x>0:
			if isLeft:
				if canTurn == true:
					$AnimatedSprite2D.flip_h = !isLeft
					$hazardArea/CloseAttack.position = $hazardArea/CloseAttack.position * -1
					$hazardArea/jabAttack.position = $hazardArea/jabAttack.position* -1
					$CloseAttackDetection.scale = $CloseAttackDetection.scale * -1
					isLeft = false
>>>>>>> Stashed changes:enemies/test enemy/enemyTest.gd
	


func _on_health_dead():
	if currentState != States.Dead:
		changeState(States.Dead)


func _on_animation_player_animation_finished(anim_name):
<<<<<<< Updated upstream:enemyTest.gd
	if anim_name == "Dead":
		$AnimationPlayer.pause()
		await get_tree().create_timer(3).timeout
		queue_free()
=======
	match anim_name:
		"Dead":
			await get_tree().create_timer(3).timeout
			$AnimationPlayer.stop()
			queue_free()
		"closeAttack":
			canTurn = true
			cooldown = 1
			coolingDown = true
			changeState(States.Move)
		"farAttack":
			canTurn = true
			cooldown = 2
			coolingDown = true
			changeState(States.Move)
	
	#if anim_name == "Dead":
>>>>>>> Stashed changes:enemies/test enemy/enemyTest.gd
		
	if anim_name == "closeAttack":
		#$AnimationPlayer.pause()
		cooldown = 2
		coolingDown = true
		changeState(States.Move)
		
	if anim_name == "farAttack":
		cooldown = 2
		coolingDown = true
		changeState(States.Move)
