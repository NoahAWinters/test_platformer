class_name PlayerWithFSM
extends Entity

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var landing_sound: AudioStreamPlayer2D = $LandingSound
@onready var camera: Camera2D = $Camera
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var landing_intesnity = 2.25;
@export var landing_effect_duration = .25

#general
const SPEED               = 300.0
const JUMP_VELOCITY       = -850.0 #-400.0
const GROUND_ACCELERATION = 1300.0; 
const GROUND_FRICTION     = 1700.0;
const AIR_ACCELERATION    = 500.0;
const AIR_FRICTION        = 500.0;
var direction
#Jump Juice
const CORNER_CORRECTION_AMOUNT = 14;
const COYOTE_TIME              = 0.20  # still jumpable just after leaving a ledge
const JUMP_BUFFER              = 0.12  # a press just before landing still counts
const JUMP_CUT                 = 0.45
var _coyote_timer: float;
var _jump_buffer_timer: float;
var _max_jumps = 2;
var num_jumps = 0;
var was_airborne := false
var can_press_jump = false
var is_falling = true
#Asymetric Gravity
const RISE_GRAVITY_MULT    = 0.9     # a little floaty going up
const FALL_GRAVITY_MULT    = 2.0    # snappier coming down
const FAST_FALL_MULT       = 1.75
const APEX_SPEED_THRESHOLD = 45.0    # |vertical speed| under this = near the peak
const APEX_GRAVITY_MULT    = 0.55    # extra-light gravity for a "hang"
const MAX_FALL_SPEED       = 500.0   # terminal velocity

var player_delta

enum States {IDLE, RUN, JUMP, FALL,}

# This variable keeps track of the character's current state.
var  current_state: States = States.IDLE
var previous_state



func _ready() -> void:
	if Game.playerFSM == null:
		Game.playerFSM = self
	animation_player.play("RESET")

func _process(_delta:float) -> void:
	#Sprite Direction
	if(direction > 0):
		sprite.flip_h = false
	elif(direction < 0):
		sprite.flip_h = true

func _physics_process(delta: float) -> void:
	#if Input.is_action_just_released("jump"):
		#can_press_jump = true
	direction = Input.get_axis("left", "right")
	_reset_squash_and_stretch(delta)

func _reset_squash_and_stretch(delta:float):
	sprite.scale.x = move_toward(sprite.scale.x, 1.0, 3 * delta)
	sprite.scale.y = move_toward(sprite.scale.y, 1.0, 3 * delta)
	
func _move_player(_delta: float) -> void:
	pass
	# Get the input direction and handle the movement/deceleration.		
	#if(direction):
		#var acceleration = set_acceleration()
		#velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
	#else:
		#var friction = set_friction()
		#velocity.x = move_toward(velocity.x, 0, friction * delta)
#
	#_attempt_corner_correction(delta, CORNER_CORRECTION_AMOUNT)
		## Animate
	#handle_animation()
	#handle_gravity(delta)
	#handle_jump(delta)
	#move_and_slide()
	

func handle_gravity(delta: float) -> void :
	var _gravity = 2500
	var mult
	
	if current_state == States.IDLE:
		if was_airborne:
			#land
			num_jumps = 0
			was_airborne = false
			is_falling = false
			camera.screen_shake(landing_intesnity, landing_effect_duration)
			Juice.play_sfx(landing_sound)
		
	elif current_state == States.RUN:
		if was_airborne:
			#land
			num_jumps = 0
			was_airborne = false
			is_falling = false
			camera.screen_shake(landing_intesnity, landing_effect_duration)
			Juice.play_sfx(landing_sound)
			
	elif current_state == States.JUMP:
		was_airborne = true
		if(velocity.y < 0.0): #going up
			mult = RISE_GRAVITY_MULT
			if Input.is_action_just_released("jump") and velocity.y < 0.0:
				velocity.y *= JUMP_CUT
			Juice.spawn_ghost(sprite, scale)
		if absf(velocity.y) < APEX_SPEED_THRESHOLD:
			mult *= APEX_GRAVITY_MULT   # ease off at the top of the arc
		if Input.is_action_pressed("down"):#fast fall
			mult *= FAST_FALL_MULT
		elif Input.is_action_just_released("jump") and velocity.y < 0.0:
			velocity.y *= JUMP_CUT
		#Apply Gravity
		velocity.y += _gravity * mult * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
			
	elif current_state == States.FALL:
		was_airborne = true
		is_falling = true
		mult = FALL_GRAVITY_MULT
		if absf(velocity.y) < APEX_SPEED_THRESHOLD:
			mult *= APEX_GRAVITY_MULT   # ease off at the top of the arc
		if Input.is_action_pressed("down"):#fast fall
			mult *= FAST_FALL_MULT
		elif Input.is_action_just_released("jump") and velocity.y < 0.0:
			velocity.y *= JUMP_CUT
		#Apply Gravity
		velocity.y += _gravity * mult * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	if not is_on_floor():
		was_airborne = true
		if(velocity.y < 0.0): #going up
			mult = RISE_GRAVITY_MULT
			if Input.is_action_just_released("jump") and velocity.y < 0.0:
				velocity.y *= JUMP_CUT
			Juice.spawn_ghost(sprite, scale)
		else: #going down
			is_falling = true
			mult = FALL_GRAVITY_MULT
		if absf(velocity.y) < APEX_SPEED_THRESHOLD:
			mult *= APEX_GRAVITY_MULT   # ease off at the top of the arc
		if Input.is_action_pressed("down"):#fast fall
			mult *= FAST_FALL_MULT
		elif Input.is_action_just_released("jump") and velocity.y < 0.0:
			velocity.y *= JUMP_CUT
		#Apply Gravity
		velocity.y += _gravity * mult * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	elif is_on_floor():	
		if was_airborne:
			#land
			num_jumps = 0
			was_airborne = false
			is_falling = false
			#camera.screen_shake(landing_intesnity, landing_effect_duration)
			Juice.play_sfx(landing_sound)
			sprite.scale = Juice.squash()

func handle_jump(delta: float) :
	#COYOTE TIME
	if(is_on_floor()):
		_coyote_timer = COYOTE_TIME;
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)
	#JUMP BUFFER
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)
		
	# A buffered press plus coyote grace = a jump. Neither has to be exact
	if(can_press_jump):
		if (_coyote_timer > 0.0 and _jump_buffer_timer > 0.0):
				jump(1)
		elif num_jumps >= 1 or is_falling:
			if(Input.is_action_just_pressed("jump")):
				##jumps from ground cost 2
				jump(2)

func jump(cost:int):
	can_press_jump = false
	if num_jumps >= _max_jumps: return
	is_falling = false
	num_jumps += cost;
	var current_velocity = velocity
	
	if(num_jumps <= 1):
		if not animation_player.current_animation == ("jump"):
			animation_player.play("jump")
	else:
		if not animation_player.current_animation == ("flip"):
			animation_player.play("flip")
			##velocity = Vector2.ZERO
	
	velocity.y = JUMP_VELOCITY
	velocity.x = abs(current_velocity.x) * direction
	Juice.play_sfx(jump_sound)#jump_sound.play() #RANDOMIZE PITCH
	sprite.scale = Juice.stretch() #Squash and ->Stretch

func handle_animation():
	
		
	#States
	if current_state == States.FALL:
		if velocity.y > 0.0:
			if was_airborne and not is_falling:
				if not animation_player.current_animation == ("fall"):
					animation_player.play("fall")
				is_falling = true
	
	elif current_state == States.JUMP:
		if not animation_player.current_animation == ("jump"):
			animation_player.play("jump")
	
	elif current_state == States.RUN: 
		if(velocity.x > 1 or velocity.x < -1):
				animation_player.play("run")
				if was_airborne:
					sprite.scale = Juice.squash()
		
	elif current_state == States.IDLE:
			animation_player.play("idle")
			if was_airborne:
				sprite.scale = Juice.squash()

func _attempt_corner_correction(delta: float, amount: int):
	if velocity.y < 0 and test_move(global_transform, Vector2(0, velocity.y * delta)):
		for i in range(1, amount+1):
			for j in [-1.0, 1.0]:
				if not test_move(global_transform.translated(Vector2(i*j, 0)), 
				Vector2(0, velocity.y * delta)):
					translate(Vector2(i*j, 0))
					global_position.x = round(global_position.x/16)*16 -1.99 *j 
					if velocity.x * j < 0: velocity.x = 0;
					return

func set_acceleration() -> float:
	var _acceleration = GROUND_ACCELERATION;
	if not is_on_floor():
		_acceleration = AIR_ACCELERATION;
	return _acceleration;

func set_friction() -> float:
	var _friction = GROUND_FRICTION;
	if not is_on_floor():
		_friction = AIR_FRICTION;
	return _friction;

func force_jump():
	num_jumps = 0
	jump(0)
	
func set_state(new_state: int) -> void:
	previous_state = current_state
	if new_state == States.IDLE:
		pass
	if new_state == States.RUN:
		pass
	if new_state == States.JUMP:
		pass
	if new_state == States.FALL:
		pass

func play_animation(anim:String):
	if(animation_player != null):
		animation_player.play(anim)
		
func get_direction() -> float:
	return direction
