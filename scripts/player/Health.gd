extends Node2D
class_name Player

@export var maxHealth : int
var health : int
@export var maxStamina : int
var stamina : int

var staminaCharged = false
@onready var staminaBar = $"../Resources/staminaBar"

func _ready():
	health = maxHealth
	stamina = maxHealth
	staminaBar.max_value = maxStamina

func _process(_delta):
	#passive stamina recharge
	if stamina < maxStamina:
		if staminaCharged == false:
			staminaCharged = true
			stamina +=1
			#(stamina)
			await get_tree().create_timer(3).timeout
			staminaCharged = false
	
	#stamina bar control
	if stamina == maxStamina:
		staminaBar.hide()
	else: staminaBar.show()
	changeBar()
	

func changeBar():
	staminaBar.value = stamina
