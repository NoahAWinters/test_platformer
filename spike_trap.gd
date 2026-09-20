extends Enemy



func _player_directionless():
	sprite.scale = Juice.squash(squash_min, squash_max)
	_hurt_player()
