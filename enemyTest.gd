extends CharacterBody2D

#states
enum States{Move, CloseAttack, FarAttack, JumpAttack, Dead}
var currentState = States.Move
var playerPos 
var targetPos
var targetDist

@onready var animation_tree = $AnimationTree

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
	var query = PhysicsRayQueryParameters2D.create(self.position, get_tree().get_first_node_in_group("player").position,2)
	var result = space_state.intersect_ray(query)
	if result:
		playerPos = to_local(result.position)
	
	#attacks called through match case
	match currentState:
		States.Move:
			$AnimationPlayer.play("move")
			Move(delta)
		States.CloseAttack:
			if cooldown <=0:
				CloseAttack()
			else: changeState(States.Move)
		States.FarAttack:
			targetDist = sqrt((result.position.x - self.position.x)**2)
			FarAttack()
		States.Dead:
			velocity.x = 0
			$AnimationPlayer.play("Dead")
			
			
	
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
	await $AnimationPlayer.animation_finished
	cooldown = 2
	coolingDown = true
	changeState(States.Move)


func FarAttackCheck():
	if currentState == States.Move && cooldown<=0:
		if sqrt((playerPos.x **2)+(playerPos.y**2)) >= FAR_ATTACK_RANGE:#measures raycast distance to player
			targetPos = playerPos #does not stop at players position
			changeState(States.FarAttack)
			#print(to_global(targetPos))


func FarAttack():
	
	print(targetDist)
	
	# d = √((x2-x1)2 + (y2-y1)2)
	#move toward player
	if targetPos.x < 0:
		velocity.x = move_toward(velocity.x,  targetPos.x, 500)
	elif targetPos.x > 0: 
		velocity.x = move_toward(velocity.x, targetPos.x, 500)
	
	#find distance, when distance <=0 stop
	if round(targetDist) <= 3:
		print("arrived")
		velocity.x = 0
		attackBox(0,2) #replace with dash attack anim
		cooldown = 2
		coolingDown = true
		changeState(States.Move)
	else:
		await get_tree().create_timer(3).timeout
		cooldown = 5
		#print(cooldown)
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
func flip():
	if playerPos.x < 0:
		$AnimatedSprite2D.flip_h = (playerPos.x<0)
		if !isLeft:
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
	


func _on_health_dead():
	if currentState != States.Dead:
		changeState(States.Dead)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Dead":
		$AnimatedSprite2D.pause()
		#why does anim keep playing
		queue_free()
