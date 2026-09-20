extends PlayerState

var state_forced:bool = false

func enter_state():		
	if player.num_jumps > player.max_jumps:
		return
		
		
	if(player.num_jumps < player.max_jumps - 1):
		player.animation_player.play("jump")
	else:
		player.animation_player.play("flip")
		
	player.velocity.y = 0
	Juice.play_sfx(player.jump_sound)
	jump(player.jump_multiplier)
	player.num_jumps += 1

func exit_state():
	player.jump_multiplier = 1

func update(delta:float):	
	player.jump_buffer_timer = max(player.jump_buffer_timer - delta, 0.0)
	
func physics_update(delta:float):
	if(player.direction):
		var acceleration = player.AIR_ACCELERATION
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, acceleration * delta)
	else:
		var friction = player.AIR_FRICTION
		player.velocity.x = move_toward(player.velocity.x, 0, friction * delta)
		
	#Apply Gravity
	var mult:float = 1.0
	if not player.is_on_floor():
		if(player.velocity.y < 0.0): #going up
			mult = player.RISE_GRAVITY_MULT
			if not state_forced:
				if Input.is_action_just_released("jump") and player.velocity.y < 0.0:
					player.velocity.y *= player.JUMP_CUT
			Juice.spawn_ghost(player.sprite, player.scale)
		#else: #going down
		if Input.is_action_pressed("down"):#fast fall
			mult *= player.FAST_FALL_MULT
		#Apply Gravity
		player.velocity.y += player.GRAVITY * mult * delta
		player.velocity.y = min(player.velocity.y, player.MAX_FALL_SPEED)

func jump(multipler:float = 1):
	if player.num_jumps >= player.max_jumps: return

	var current_velocity = player.velocity * multipler
	
	player.velocity.y = player.JUMP_VELOCITY * multipler
	player.velocity.x = abs(current_velocity.x) * player.direction
	player.sprite.scale = Juice.stretch(player.squash_min, player.squash_max)#Squash and ->Stretch
