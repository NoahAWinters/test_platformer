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
@export var death_state:PlayerState


#generals
var direction:float
var last_direction:float = 1

#Jump Juice
const CORNER_CORRECTION_AMOUNT = 14;
const COYOTE_TIME              = 0.20  # still jumpable just after leaving a ledge
const JUMP_BUFFER              = 0.12  # a press just before landing still counts
const JUMP_CUT                 = 0.45
var coyote_timer: float;
var jump_buffer_timer: float;
var max_jumps = 2
var num_jumps = 0;
var squash_min = 0.75 #0.70
var jump_multiplier = 1.0
var squash_max = 1.25#1.30

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
	check_switch_states()

func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)
	_attempt_corner_correction(delta, CORNER_CORRECTION_AMOUNT)
	move_and_slide()

func check_switch_states():
	prints("Current state is", str(current_state))
	match current_state:
		knockback_state:
			if knockback_timer <= 0 and not knockback_state.state_forced:
				switch_state(fall_state)
			elif knockback_state.state_forced  and is_on_floor():
				switch_state(idle_state)
		idle_state:
			if direction:
				switch_state(run_state)
			elif (coyote_timer > 0.0 and jump_buffer_timer > 0.0):
						switch_state(jump_state)
			elif coyote_timer <= 0:
				switch_state(fall_state)
		run_state:
			if not direction:
				switch_state(idle_state)
			elif coyote_timer <= 0:
				switch_state(fall_state)
			elif num_jumps < max_jumps:
				if (coyote_timer > 0.0 and jump_buffer_timer > 0.0):
					switch_state(jump_state)
		jump_state:
			if (velocity.y > 0.0 or is_on_floor()):
				switch_state(fall_state)
		fall_state:
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
	#knockback = _direction * -last_direction * force
	#knockback_timer = knockback_duration
	##switch_state(knockback_state)
	##set_state(States.KNOCKBACK)

func force_knockback(_enemy:Entity, force:float, knockback_duration: float, prohibit_exit:bool = false):
	var knock = _enemy.global_position - global_position.normalized()
		
	knockback_state.direction = knock
	knockback_state.force = force
	knockback_state.knockback_duration = knockback_duration
	knockback_state.last_facing = last_direction
	knockback_state.state_forced = prohibit_exit
	switch_state(knockback_state)

func force_jump(multiplier:float):
	num_jumps = 0
	jump_multiplier = multiplier
	jump_state.state_forced = true
	switch_state(jump_state)

func force_direction(new_direction:int):
	direction = new_direction

func is_falling():
	return current_state == fall_state

func force_death():
	Game.prevent_input = true
	switch_state(death_state)

func _on_coin_detector_area_entered(body: Node2D) -> void:
	if body is Collectible:
		print("Coin")
		body.collect()
