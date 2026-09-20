extends Control
@onready var anim: AnimationPlayer = $AnimationPlayer
@export var options_menu: Control

@export var _delay:float = 0.15



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("RESET")
	resume()
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _test_esc() -> void:
	if Input.is_action_just_pressed("pause"):
		if not get_tree().paused:
			pause()
		else:
			resume()

func resume():
	hide()
	get_tree().paused = false
	anim.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	anim.play("blur")
	show()
	

func _on_resume_pressed() -> void:
	await get_tree().create_timer(_delay).timeout
	resume()

func _on_restart_pressed() -> void:
	await get_tree().create_timer(_delay).timeout
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	await get_tree().create_timer(_delay).timeout
	get_tree().quit()
	
func _on_options_pressed() -> void:
	await get_tree().create_timer(_delay).timeout
	options_menu.open()
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	_test_esc()
