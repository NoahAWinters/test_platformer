extends Camera2D

#screen shake
var _shake_intensity: float    = 0.0
var _active_shake_time: float  = 0.0
var _shake_time: float         = 0.0

var shake_decay: float        = 5.0
var shake_time_speed: float   = 20.0

#dynamic lookahead
@export var look_ahead_amount = 300.0
@export var shift_speed = 0.20

func _physics_process(delta: float) -> void:
	if _active_shake_time > 0:
		_shake_time += delta * shake_time_speed
		_active_shake_time -= delta
		
		offset = Vector2(
			Juice.noise.get_noise_2d(_shake_time,0) * _shake_intensity,
			Juice.noise.get_noise_2d(0, _shake_time) * _shake_intensity,
		)
		
		_shake_intensity = max(_shake_intensity - shake_decay * delta, 0)
	else:
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)
	
	_dynamic_lookahead(delta)

func screen_shake(intensity : int, time: float):
	randomize()
	var _noise = Juice.noise
	_noise.seed = randi()
	_noise.frequency = 2.0
	
	_shake_intensity = intensity
	_active_shake_time = time
	_shake_time = 0.0

func _dynamic_lookahead(delta : float):
	var player_vel = owner.velocity
	var target_offset = Vector2.ZERO
	
	# Only shift if moving significantly
	if player_vel.length() > 20.0:
		target_offset = player_vel.normalized() * look_ahead_amount
		
	# Smoothly move towards target offset
	offset = offset.lerp(target_offset, shift_speed * delta)
