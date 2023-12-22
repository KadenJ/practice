extends CharacterBody2D

#states
enum States{Move, CloseAttack, FarAttack, JumpAttack}
var currentState = States.Move
var playerPos 
var targetPos

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(position, get_tree().get_first_node_in_group("player").position,2)
	var result = space_state.intersect_ray(query)
	if result:
		playerPos = to_local(result.position)
	
	
	#attacks called through match case
	match currentState:
		States.Move:
			Move(delta)
		States.CloseAttack:
			if cooldown <=0:
				CloseAttack()
		States.FarAttack:
			
			FarAttack(targetPos, delta)
	
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
		

func _on_player_detection_body_entered(_body): #detects player to start up attack
	#stop movement
	velocity.x = 0
	if currentState == States.Move:
		changeState(States.CloseAttack)

func changeState(newState):
	currentState = newState
	print("state = %s" %currentState)


func CloseAttack():
		
	#turns on attack hitbox 
	$hazardArea/CloseAttack.disabled = false
	$hazardArea.set_deferred("monitorable", true)
	#change to wait for certain frame  of animation
	
	await get_tree().create_timer(2).timeout
	
	$hazardArea.set_deferred("monitorable", false)
	$hazardArea/CloseAttack.disabled = true
	cooldown = 2
	coolingDown = true
	changeState(States.Move)


func FarAttackCheck():
	if currentState == States.Move && cooldown<=0:
		if sqrt((playerPos.x **2)+(playerPos.y**2)) >= FAR_ATTACK_RANGE:#measures raycast distance to player
			targetPos = playerPos
			changeState(States.FarAttack)


func FarAttack(newPosition : Vector2, delta):
	velocity.x = move_toward(velocity.x, newPosition.x, 500)
	#dash attack
	print("6H")
	
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
		print("walk")
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
		$Sprite2D.flip_h = (playerPos.x<0)
		if !isLeft:
			$Sprite2D.flip_h = !isLeft
			$hazardArea/CloseAttack.position = $hazardArea/CloseAttack.position * -1
			$CloseAttackDetection.scale = $CloseAttackDetection.scale * -1
			isLeft = true
	if playerPos.x>0:
		if isLeft:
			$Sprite2D.flip_h = !isLeft
			$hazardArea/CloseAttack.position = $hazardArea/CloseAttack.position * -1
			$CloseAttackDetection.scale = $CloseAttackDetection.scale * -1
			isLeft = false
	

