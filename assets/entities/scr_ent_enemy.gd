class_name Enemy
extends CharacterBody2D

@export var death_fx:GPUParticles2D
@export var flash_player: AnimationPlayer
@export var max_health:int = 1
var _current_health:int
@export var hurt_sound:AudioStreamPlayer2D
@onready var coll: CollisionShape2D = $CollisionShape2D

@export var squash_min = 0.75 #0.70
@export var squash_max = 1.5#1.30

@export var _speed: float = 0
@export var sprite:AnimatedSprite2D
@export var dmg:int
@export var bounce_factor:float = .75;

func _ready() -> void:
	_current_health = max_health
	
	if not (death_fx == null):
		death_fx.emitting = false
	if(flash_player != null):
		flash_player.play("RESET")


func _process(delta: float) -> void:
	if(_current_health > 0):
		velocity.x = _speed 
		sprite.scale.x = Juice.reset_squash_and_stretch(sprite.scale.x,delta)
		sprite.scale.y = Juice.reset_squash_and_stretch(sprite.scale.y,delta)
		move_and_slide()
	
	
func die():
	Juice.try_emit_vfx(death_fx, true)
	velocity = Vector2.ZERO
	coll.set_deferred("disabled", true)
	#
	flash_player.play("flash")
	sprite.scale = Juice.squash(1.5,.5)
	await Utility.wait(.1)
	
	#queue_free()
	
	sprite.visible = false

func _on_wall_detector_body_entered(_body: Node2D) -> void:
	if _current_health <= 0:
		return
	
	_speed = -_speed
	sprite.flip_h = !sprite.flip_h
	pass

func _on_player_detectors_body_entered(body: Node2D) -> void:
	if _current_health <= 0:
		return
	
	if body.name == "Player":
		_player_directionless()
		if(Game.player.position.y < global_position.y):
			_player_from_above()
		if Game.player.is_falling():
			_player_falling()
		else:
			_player_from_side()
			
func _player_from_side():
	pass

func _player_from_above():
	pass
	
func _player_falling():
	pass
	
func _player_directionless():
	pass
	
func _hurt_player():
	Game.damage_player(dmg, self)

func _take_damage(damage:int):
	_current_health -= damage
	if(hurt_sound != null):
		Juice.play_sfx(hurt_sound)
	if _current_health <= 0:	
		die()
