extends Entity



func _player_directionless():
	sprite.scale = Juice.squash(squash_min, squash_max)
	Game.damage_player(dmg, self)
	
func _player_from_side():
	sprite.scale = Juice.squash(squash_min, squash_max)
	Game.damage_player(dmg, self)
