class_name Collectible
extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var coll: CollisionShape2D = $CollisionShape2D
@onready var collect_sound: AudioStreamPlayer2D = $CollectSound

@export var score_bonus = 1
@export var health_bonus = 0


func collect():
	Game.add_coins(score_bonus)
	Game.add_health(health_bonus)
	Juice.spawn_text(Utility.get_cool_word_random(), position)
	Juice.play_sfx(collect_sound)
	coll.set_deferred("disabled", true)
	hide()

func _on_body_entered(body) -> void:
	if(body.name == "Player/CoinDetector"):
		collect()

func _process(_delta) -> void:
	position.y += Move.get_sin(.15, .5) 
