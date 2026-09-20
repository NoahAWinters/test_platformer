extends Enemy
@onready var explosion: GPUParticles2D = $Explosion

func _player_from_side():
	print("Outch, touched a slime")
	_hurt_player()
	
func _player_falling():
	#Juice.spawn_text("side", position)
	Game.player.force_jump(0.80)
	_take_damage(1)
	
