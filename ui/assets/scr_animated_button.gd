class_name AnimatedButton
extends Button

@export var default:bool = false

const REST_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.15, 1.15)
const SQUASH_SCALE := Vector2(1.5, 0.85)

const REST_TIME := 0.2
const HOVER_TIME := 0.3
const SQUASH_TIME := 0.1

var _tween:Tween = null

func _ready() -> void:
	offset_transform_enabled = true
	if default:
		grab_focus()

func _restart_tween() -> Tween:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	return _tween


func hover_tween():
	_restart_tween().tween_property(self, "offset_transform_scale", HOVER_SCALE, HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func exit_tween():
	_restart_tween().tween_property(self, "offset_transform_scale", REST_SCALE, REST_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_mouse_entered() -> void:
	hover_tween()
	
func _on_mouse_exited() -> void:
	exit_tween()
	
func _on_button_down() -> void:
	_restart_tween().tween_property(self, "offset_transform_scale", SQUASH_SCALE, SQUASH_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _on_button_up() -> void:
	_restart_tween().tween_property(self, "offset_transform_scale", HOVER_SCALE, HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


func _on_focus_entered() -> void:
	hover_tween()


func _on_focus_exited() -> void:
	exit_tween()
