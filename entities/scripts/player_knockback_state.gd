extends PlayerState

var direction: Vector2
var force:float
var knockback_duration:float
var last_facing:int

# Called when the node enters the scene tree for the first time.
func enter_state():
	player.animation_player.play("hurt")
	#jump()

func exit_state():
	player.jump_multiplier = 1

func physics_update(delta:float):
	player.velocity = direction * -last_facing * force
	#Apply Gravity
	var mult =  Move.FALL_GRAVITY_MULT * 3.5
	
	player.velocity.y +=  Move.GRAVITY * mult * delta
	player.velocity.y = min( player.velocity.y,  Move.MAX_FALL_SPEED)
