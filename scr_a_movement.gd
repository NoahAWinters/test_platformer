extends Node

#Asymetric Gravity
const GRAVITY             = 2500
const RISE_GRAVITY_MULT    = 0.9     # a little floaty going up
const FALL_GRAVITY_MULT    = 2.0    # snappier coming down
const FAST_FALL_MULT       = 1.75
const APEX_SPEED_THRESHOLD = 45.0    # |vertical speed| under this = near the peak
const APEX_GRAVITY_MULT    = 0.55    # extra-light gravity for a "hang"
const MAX_FALL_SPEED       = 500.0   # terminal velocity
const SPEED               = 300.0
const JUMP_VELOCITY       = -850.0 #-400.0
const GROUND_ACCELERATION = 1300.0; 
const GROUND_FRICTION     = 1700.0;
const AIR_ACCELERATION    = 500.0;
const AIR_FRICTION        = 500.0;

const JUMP_CUT               = 0.45


func ground_move(body:CharacterBody2D, direction:float, delta:float):
	if(direction):
		body.velocity.x = move_toward(body.velocity.x, direction * SPEED, GROUND_ACCELERATION * delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, GROUND_FRICTION * delta)

func air_move(body:CharacterBody2D, direction:float, delta:float):
	if(direction):
		body.velocity.x = move_toward(body.velocity.x, direction * SPEED, AIR_ACCELERATION * delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, AIR_FRICTION * delta)

func apply_gravity(body:CharacterBody2D, mult:float, delta:float):
	var new_mult = mult
	if absf( body.velocity.y) < APEX_SPEED_THRESHOLD:
		new_mult *=  APEX_GRAVITY_MULT   # ease off at the top of the arc
	if Input.is_action_pressed("down"):#fast fall
		new_mult *=  FAST_FALL_MULT
	elif body is Player:
		if Input.is_action_just_released("jump") and  body.velocity.y < 0.0:
			body.velocity.y *=  JUMP_CUT
	#Apply Gravity
	body.velocity.y +=  GRAVITY * new_mult * delta
	body.velocity.y = min( body.velocity.y,  MAX_FALL_SPEED)

func get_sin(amp:float = 1, freq:float = 1) -> float:
	return sin(Game.time * freq) * amp
