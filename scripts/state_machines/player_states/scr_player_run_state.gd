extends PlayerState

func enter_state():
	player.num_jumps = 0


func exit_state():
	pass

func update(delta:float):
	player.animation_player.play("run")
	if(player.is_on_floor()):
		player.coyote_timer = player.COYOTE_TIME;
	else:
		player.coyote_timer = max(player.coyote_timer - delta, 0.0)
	
func physics_update(delta:float):
	#Apply Move
	if(player.direction):
		var acceleration = player.GROUND_ACCELERATION
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, acceleration * delta)
	else:
		var friction = player.GROUND_FRICTION
		player.velocity.x = move_toward(player.velocity.x, 0, friction * delta)
		
	if not player.is_on_floor():
		var mult
		mult = player.FALL_GRAVITY_MULT
		if absf(player.velocity.y) < player.APEX_SPEED_THRESHOLD:
			mult *= player.APEX_GRAVITY_MULT   # ease off at the top of the arc
		if Input.is_action_pressed("down"):#fast fall
			mult *= player.FAST_FALL_MULT
		elif Input.is_action_just_released("jump") and player.velocity.y < 0.0:
			player.velocity.y *= player.JUMP_CUT
		#Apply Gravity
		player.velocity.y += player.GRAVITY * mult * delta
		player.velocity.y = min(player.velocity.y, player.MAX_FALL_SPEED)

func check_switch_states():
	if not player.direction:
		player.switch_state(player.idle_state)
	elif player.coyote_timer <= 0:
		player.switch_state(player.fall_state)
	elif player.num_jumps < player.max_jumps:
		if (player.coyote_timer > 0.0 and player.jump_buffer_timer > 0.0):
			player.switch_state(player.jump_state)
