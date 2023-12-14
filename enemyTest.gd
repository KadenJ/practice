extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_player_detection_body_entered(body): #detects player to start up attack
	print(body)
	
	$hazardArea.set_deferred("monitorable", true)
