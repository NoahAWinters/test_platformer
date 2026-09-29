class_name Enemy
extends Entity

@export var death_fx:GPUParticles2D
@export var flash_player: AnimationPlayer
@export var max_health:int = 1
var _current_health:int
@export var hurt_sound:AudioStreamPlayer2D
@export var _speed: float = 0




func add_health(amount:int):
	var new_health = clamp(_current_health, amount, max_health)
	_current_health += new_health

func take_damage(damage:int):
	_current_health -= damage
	if(_current_health <= 0):
		die()
	

func _ready() -> void:
	_current_health = max_health
	
	if not (death_fx == null):
		death_fx.emitting = false
	if(flash_player != null):
		flash_player.play("RESET")


func _process(delta: float) -> void:
	if(_current_health > 0):
		velocity.x = _speed 
		_reset_squash_and_stretch(delta)
		move_and_slide()
	else:
		die()
	
	
func die():
	Juice.try_emit_vfx(death_fx, true)
	velocity = Vector2.ZERO
	coll.disabled = true
	flash_player.play("flash")
	sprite.scale = Juice.squash(1.5,.5)
	await Utility.wait(.5)
	sprite.visible = false
	queue_free()

func _on_wall_detector_body_entered(_body: Node2D) -> void:
	if _current_health <= 0:
		return
	_speed = -_speed
	sprite.flip_h = !sprite.flip_h
	pass


func _take_damage(damage:int):
	_current_health -= damage
	if(hurt_sound != null):
		Juice.play_sfx(hurt_sound)
	if _current_health <= 0:	
		die()
