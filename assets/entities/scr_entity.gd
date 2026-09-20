class_name Entity
extends CharacterBody2D

@export var max_health:int

var _current_health;

func add_health(amount:int):
	var new_health = clamp(_current_health, amount, max_health)
	_current_health += new_health

func take_damage(damage:float):
	_current_health -= damage
	
func _die():
	pass
