extends Node2D

@export var maxHealth : int
var health : int
@export var maxStamina : int
var stamina : int

var staminaCharged = false
func _physics_process(_delta):
	#passive stamina recharge
	if stamina < maxStamina:
		if staminaCharged == false:
			staminaCharged = true
			stamina +=1
			print(stamina)
			await get_tree().create_timer(2).timeout
			staminaCharged = false
		
