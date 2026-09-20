extends Enemy

func _player_from_side():
	pass# Game.player.add_health(-1)

func _player_from_above():
	Game.player.force_jump(bounce_factor)
	sprite.scale = Juice.stretch(squash_min, squash_max)
