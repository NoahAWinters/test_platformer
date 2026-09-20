class_name Player
extends CharacterBody2D

@export var sprite: AnimatedSprite2D
@export var jump_sound: AudioStreamPlayer2D
@export var landing_sound: AudioStreamPlayer2D
@export var hurt_sound: AudioStreamPlayer2D

@export var camera: Camera2D

@onready var animation_player: AnimationPlayer = $Anims/AnimationPlayer
@onready var flash_player: AnimationPlayer = $Anims/FlashPlayer
@onready var blink_player: AnimationPlayer = $Anims/BlinkPlayer

@export var landing_intesnity = 2.25;
@export var landing_effect_duration = 0.25

@export var knockback_force = 0.15


var current_state:PlayerState
var previous_state:PlayerState
@export var idle_state:PlayerState
@export var run_state:PlayerState
@export var jump_state:PlayerState
@export var fall_state:PlayerState
@export var knockback_state:PlayerState


#general
const SPEED               = 300.0
const JUMP_VELOCITY       = -850.0 #-400.0
const GROUND_ACCELERATION = 1300.0; 
const GROUND_FRICTION     = 1700.0;
const AIR_ACCELERATION    = 500.0;
const AIR_FRICTION        = 500.0;
const GRAVITY             = 2500
var direction:float
var last_direction:float = 1

#Jump Juice
const CORNER_CORRECTION_AMOUNT = 14;
const COYOTE_TIME              = 0.20  # still jumpable just after leaving a ledge
const JUMP_BUFFER              = 0.12  # a press just before landing still counts
const JUMP_CUT                 = 0.45
var coyote_timer: float;
var jump_buffer_timer: float;
var max_jumps = 2#4;#Air jumps cost 2, ground jumps cost 1
var num_jumps = 0;
#var was_airborne := false
#var can_press_jump = false
#var is_falling = true
#var fall_animate = false
var squash_min = 0.75 #0.70
var jump_multiplier = 1.0
var squash_max = 1.25#1.30
#Asymetric Gravity
const RISE_GRAVITY_MULT    = 0.9     # a little floaty going up
const FALL_GRAVITY_MULT    = 2.0    # snappier coming down
const FAST_FALL_MULT       = 1.75
const APEX_SPEED_THRESHOLD = 45.0    # |vertical speed| under this = near the peak
const APEX_GRAVITY_MULT    = 0.55    # extra-light gravity for a "hang"
const MAX_FALL_SPEED       = 500.0   # terminal velocity
#Knockback
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func _ready() -> void:
	if Game.player == null:
		Game.player = self
	animation_player.play("RESET")
	current_state = idle_state
	switch_state(idle_state)	

func _process(delta):
	sprite.scale.x = Juice.reset_squash_and_stretch(sprite.scale.x,delta)
	sprite.scale.y = Juice.reset_squash_and_stretch(sprite.scale.y,delta)
	
	print(current_state)	

	if(direction != 0.0):
		last_direction = direction
	direction = Input.get_axis("left", "right")
	if(direction > 0):
			sprite.flip_h = false
	elif(direction < 0):
			sprite.flip_h = true
	
	current_state.update(delta)		
	#jump input
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)
	_attempt_corner_correction(delta, CORNER_CORRECTION_AMOUNT)
	move_and_slide()

	if current_state == knockback_state:
		if knockback_timer <= 0:
			switch_state(fall_state)
	
	if current_state == idle_state:
		if direction:
			switch_state(run_state)
		elif (coyote_timer > 0.0 and jump_buffer_timer > 0.0):
					switch_state(jump_state)
		elif coyote_timer <= 0:
			switch_state(fall_state)
	
	if current_state == run_state:
		if not direction:
			switch_state(idle_state)
		elif coyote_timer <= 0:
			switch_state(fall_state)
		elif num_jumps < max_jumps:
			if (coyote_timer > 0.0 and jump_buffer_timer > 0.0):
				switch_state(jump_state)
			
	if current_state == jump_state:
		if (velocity.y > 0.0 and !jump_state.state_forced):
			switch_state(fall_state)
			#set_state(States.FALL)
			
	if current_state == fall_state:
		if is_on_floor():
			switch_state(idle_state)
		elif num_jumps < max_jumps and jump_buffer_timer > 0:
			switch_state(jump_state)


func switch_state(new_state:PlayerState):
	previous_state = current_state
	current_state = new_state
	
	previous_state.exit_state()
	current_state.enter_state()


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


#func apply_knockback(_direction: Vector2, force:float, knockback_duration: float):
	#knockback = _direction * -last_direction * force
	#knockback_timer = knockback_duration
	##switch_state(knockback_state)
	##set_state(States.KNOCKBACK)
	
func force_knockback(_direction:Vector2, force:float, knockback_duration: float):
	knockback_state.direction = _direction
	knockback_state.force = force
	knockback_state.knockback_duration = knockback_duration
	knockback_state.last_facing = last_direction
	switch_state(knockback_state)

func force_jump(multiplier:float):
	num_jumps = 0
	switch_state(jump_state)
	jump_multiplier = multiplier
	
func is_falling():
	return current_state == fall_state
