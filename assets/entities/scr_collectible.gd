extends Area2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var coll: CollisionShape2D = $CollisionShape2D
@onready var collect_sound: AudioStreamPlayer2D = $CollectSound

@onready var score_bonus = 1
@onready var health_bonus = 0


func collect():
	Game.add_coins(score_bonus)
	#health += health_bonus	
	Juice.spawn_text(Utility.get_cool_word_random(), position)
	Juice.play_sfx(collect_sound)
	coll.set_deferred("disabled", true)
	hide()
	


func _on_body_entered(body) -> void:
	if(body.name == "Player"):
		collect()

func _process(_delta) -> void:
	position.y += Utility.get_sin(.15, .5) 
