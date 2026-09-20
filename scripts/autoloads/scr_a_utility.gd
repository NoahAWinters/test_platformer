extends Node

var cool_words:Array[String] = ["radical","bodacious","sick nasty", "tubular", "sweet","groovy","solid","supple","chill af", "niiiiice", "noice"]

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize() 


# Called when the node enters the scene tree for the first time.
func wait(time:float):
	return get_tree().create_timer(time).timeout

func get_sin(amp:float = 1, freq:float = 1) -> float:
	return sin(Game.time * freq) * amp

func get_cool_word(index:int) -> String:
	return cool_words[index]

func get_cool_word_random() -> String:
	var radical_line = str(cool_words.pick_random())
	var num_exclaims = randi_range(0, 2)
	var current_exlaims = 0
	while num_exclaims > current_exlaims:
		radical_line += "!"
		current_exlaims += 1
		
	return radical_line
