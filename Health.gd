extends Node2D
class_name Enemy

@export var maxHealth: int
var health
@onready var healthBar = $"../CanvasLayer/Control/ProgressBar"

func _ready():
	health = maxHealth
	healthBar.max_value = maxHealth

func _process(delta):
	healthBar.value = health

func die():
	self.queue_free()

func hit(damage :int):
	health -= damage
	
	if health <= 0:
		get_parent().queue_free()
	
