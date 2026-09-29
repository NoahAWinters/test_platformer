class_name Entity
extends CharacterBody2D


@export var squash_min = 0.75 #0.70
@export var squash_max = 1.5#1.30
@export var bounce_factor:float = .75;
@export var sprite:AnimatedSprite2D
@onready var coll: CollisionShape2D = $CollisionShape2D
@export var dmg:int = 0

func _player_from_side():
	pass

func _player_from_above():
	pass
	
func _player_falling():
	pass
	
func _player_directionless():
	pass
	
	
func _on_player_detectors_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_player_directionless()
		if(Game.player.position.y <= global_position.y) or Game.player.is_falling():
			_player_from_above()
		#if Game.player.is_falling():
			#_player_falling()
		else:
			_player_from_side()


func _process(delta: float) -> void:
	_reset_squash_and_stretch(delta)

func _reset_squash_and_stretch(delta:float):
	if sprite != null:
		sprite.scale.x = Juice.reset_squash_and_stretch(sprite.scale.x,delta)
		sprite.scale.y = Juice.reset_squash_and_stretch(sprite.scale.y,delta)
	move_and_slide()
