extends CharacterBody2D

enum States{Move, CloseAttack, FarAttack, JumpAttack}
var currentState = States.Move

@onready var timer = $PlayerDetectionClose/CoolDown
var cooldown : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var coolingDown = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#attacks called through match case
	match currentState:
		States.Move:
			Move()
		States.CloseAttack:
			if cooldown <=0:
				CloseAttack()
			
	
	coolDownCheck()

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
	$hazardArea.set_deferred("monitorable", true)
	#change to wait for certain frame  of animation
	
	await get_tree().create_timer(2).timeout
	
	$hazardArea.set_deferred("monitorable", false)
	cooldown = 2
	coolingDown = true
	changeState(States.Move)

var isDone = false
func Move():
	if isDone == false:
		isDone = true
		await get_tree().create_timer(1).timeout
		print("walk")
		isDone = false
	


func _on_timer_timeout():
	cooldown = 0 
