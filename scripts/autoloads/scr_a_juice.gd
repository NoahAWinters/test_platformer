extends Node
var noise = FastNoiseLite.new()
var rando = RandomNumberGenerator.new()



var max_ghost = 0.14

var audio_pitch_range = .1

func stretch(squash_min:float, squash_max:float) -> Vector2:
	return Vector2(squash_max, squash_min)

func squash(stretch_min:float, stretch_max:float) -> Vector2:
	return Vector2(stretch_min, stretch_max)

func play_sfx(player: AudioStreamPlayer2D):
	player.pitch_scale = randf_range(1 - audio_pitch_range, 1 + audio_pitch_range)
	player.play()

#func spawn_impact(path: String, pos: Vector2):
	#var p = preload().instantiate()
	#p.position = pos
	#p.emitting = true
	#get_tree().current_scene.add_child(p)
	#
	## Auto-cleanup
	#await p.finished
	#p.queue_free()
	
func spawn_ghost(body, scale):
	var ghost = body.duplicate()
	ghost.material = null
	ghost.scale = scale
	ghost.modulate = Color(0.5, 0.8, 1.0, 0.5) # Blue tint
	
	get_parent().add_child(ghost)
	ghost.global_position = body.global_position
	
	var t = create_tween()
	t.tween_property(ghost, "modulate:a", 0.0,  max_ghost)
	t.tween_callback(ghost.queue_free)
	
func try_emit_vfx(vfx:GPUParticles2D, value:bool):
	if vfx is GPUParticles2D:
		vfx.emitting = value

func spawn_number(value: int, pos: Vector2):
	var label = Label.new()
	label.text = str(value)
	label.position = pos
	# Center pivot for scaling
	label.pivot_offset = label.size / 2 
	add_child(label)
	
	# Animate Jump
	var t = create_tween().set_parallel(true)
	var end_pos = pos + Vector2(randf_range(-20, 20), -50)
	
	t.tween_property(label, "position", end_pos, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	t.tween_property(label, "scale", Vector2.ZERO, 0.2).set_delay(0.4)
	t.chain().tween_callback(label.queue_free)
	
	
func reset_squash_and_stretch(scale:float, delta:float) -> float:
	return move_toward(scale, 1.0, 3 * delta)

func spawn_text(value: String, pos: Vector2):
	var label = Label.new()
	label.text = str(value)
	label.position = pos
	# Center pivot for scaling
	label.pivot_offset = label.size / 2 
	add_child(label)
	
	# Animate Jump
	var t = create_tween().set_parallel(true)
	var end_pos = pos + Vector2(randf_range(-20, 20), -50)
	
	t.tween_property(label, "position", end_pos, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	t.tween_property(label, "scale", Vector2.ZERO, 0.2).set_delay(0.4)
	t.chain().tween_callback(label.queue_free)


	
