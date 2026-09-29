extends Menu

@onready var full_screen_checkbox: CheckBox = $"GUI/VBC all/HBC Checkboxes/FullScreenCheckbox"

@onready var master_slider: HSlider = $"GUI/VBC all/MasterSlider"
@onready var music_slider: HSlider = $"GUI/VBC all/MusicSlider"
@onready var sfx_slider: HSlider = $"GUI/VBC all/SFXSlider"


@export var pause_menu: Menu

var _mas = 1
var _mus = 1
var _sfx = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	_check_vars()
	_ready_audio()
	
func _check_vars():
	var _window = get_window()
	var mode = _window.get_mode()
	full_screen_checkbox.set_pressed_no_signal(mode == Window.MODE_FULLSCREEN)
	
	
func close():
	await get_tree().create_timer(.15).timeout
	hide()#volume
	Game.pause_menu.show()
	
func open():
	await get_tree().create_timer(.15).timeout
	show()
	master_slider.value = _mas
	music_slider.value = _mus
	sfx_slider.value = _sfx
	_set_slider_values()
	default_button.grab_focus()

func save_changes():
	AudioServer.set_bus_volume_db(0, _mas)
	AudioServer.set_bus_volume_db(1, _mus)
	AudioServer.set_bus_volume_db(2, _sfx)

func _on_sfx_slider_mouse_exited() -> void:
	release_focus()


func _on_music_slider_mouse_exited() -> void:
	release_focus()


func _on_master_slider_mouse_exited() -> void:
	release_focus()


func _on_cancel_pressed() -> void:
	close()
	pause_menu.open()

func _set_slider_values():
	_mas = master_slider.value
	_mus = music_slider.value
	_sfx = sfx_slider.value

func _ready_audio():
	_mas = AudioServer.get_bus_volume_db(0)
	_mus = AudioServer.get_bus_volume_db(1)
	_sfx = AudioServer.get_bus_volume_db(2)
	master_slider.value = _mas
	music_slider.value = _mus
	sfx_slider.value = _sfx
	AudioServer.set_bus_volume_db(0, master_slider.value)
	AudioServer.set_bus_volume_db(1, music_slider.value)
	AudioServer.set_bus_volume_db(2, sfx_slider.value)


		
func center_window():
	var _center = Vector2(DisplayServer.screen_get_position()) + (DisplayServer.screen_get_size() / 2.0)
	var _window_size = get_window().get_size_with_decorations()
	get_window().set_position(_center - (_window_size / 2.0))	

func _on_full_screen_checkbox_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1280, 720))


func _on_apply_pressed() -> void:
	save_changes()
	_set_slider_values()
	close()
