extends Entity

func _player_from_side():
	pass
	
func _player_from_above():
	bounce()

func _player_falling():
	bounce()

func bounce():
	var mod = 1
	if Input.is_action_pressed("jump"):
		mod = 1.25
	Game.player.force_jump(bounce_factor * mod)
	sprite.scale = Juice.stretch(squash_min, squash_max)
	
