extends Node2D



func _on_hazard_area_body_entered(body):
	queue_free()
	#need to change this to add to inventory
	var stars = get_tree().get_nodes_in_group("Stars")
	if stars.size() == 1:
		Events.levelCompleted.emit()
		#print("level completed")
