extends PlayerState

var direction: Vector2
var force:float
var knockback_duration:float
var last_facing:int

# Called when the node enters the scene tree for the first time.
func enter_state():
	player.animation_player.play("idle")

func exit_state():
	player.jump_multiplier = 1

func physics_update(_delta:float):
	player.velocity = direction * -last_facing * force
	#player.knockback_timer = player.knockback_duration
	
