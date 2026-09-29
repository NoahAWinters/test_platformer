extends PlayerState

func enter_state():
	die()

func exit_state():
	pass

@warning_ignore("unused_parameter")
func update(delta:float):
	pass
	
@warning_ignore("unused_parameter")
func physics_update(delta:float):
	pass


func die():
	#player.Juice.try_emit_vfx(player.death_fx, true)
	#player.coll.disabled = true
	#player.flash_player.play("flash")
	#player.sprite.scale = Juice.squash(1.5,.5)
	await Utility.wait(.5)
	player.sprite.visible = false
	
