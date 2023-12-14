extends Node2D
class_name Enemy

@export var maxHealth: int
var health

func _ready():
	health = maxHealth

func die():
	self.queue_free()

func hit(damage :int):
	health -= damage
	
	if health <= 0:
		get_parent().queue_free()
	
