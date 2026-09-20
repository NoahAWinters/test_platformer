extends Control
@export var pause_menu: Control
@export var coin_count: Label 
@export var heart_containers: HBoxContainer
@onready var player:Player

@export var max_hp = 3
const INVULNERABILITY_TIME = 200
var _invulnerability_timer:float
var _health:int = 0
var _ui_hearts : Array[TextureRect]

var _coins = 0

var time:float = 0

func _ready() -> void:
	_health = max_hp
	initialize_hearts()
	_update_heart_display()

func _process(delta: float) -> void:
	time += delta
	
	if _invulnerability_timer <= 0.0:
		player.blink_player.play("RESET")
	else:
		if _invulnerability_timer > 0.0:
			_invulnerability_timer -= 1

func add_coins(amount:int):
	_coins += amount
	coin_count.text = str(_coins)
	
func get_coins() -> int:
	return _coins
	
func set_health(hp:int):
	_health = hp
	_update_heart_display()

func damage_player(dmg:int, _enemy:Enemy):
	if(_invulnerability_timer <= 0):
		player.sprite.modulate.a = 0.5
		_health -= dmg
		_invulnerability_timer = INVULNERABILITY_TIME
		player.flash_player.play("flash")
		player.blink_player.play("blink")
		var knock = _enemy.global_position - player.global_position.normalized()
		player.force_knockback(knock, .15, .1)
		Juice.play_sfx(player.hurt_sound)
		
	
	_update_heart_display()
	#trigger damage animation
	_update_heart_display()
	
func initialize_hearts():
	for child in heart_containers.get_children():
		if child is TextureRect:
			_ui_hearts.append(child)

func set_time_scale(time_scale:float):
	Engine.time_scale = time_scale

func _update_heart_display():
	for i in range(_ui_hearts.size()):
		if i < _health:
			_ui_hearts[i].modulate = Color.WHITE
		else:
			_ui_hearts[i].modulate = Color.BLACK
