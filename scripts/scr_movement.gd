class_name Movement extends Node


func _move_with_acceleration_and_friction(delta:float, direction:float) -> void:
	#direction = Input.get_axis("left", "right")
	# Get the input direction and handle the movement/deceleration.		
	if(direction):
		var acceleration = set_acceleration()
		velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
	else:
		var friction = set_friction()
		velocity.x = move_toward(velocity.x, 0, friction * delta)
