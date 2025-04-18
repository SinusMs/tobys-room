extends Control

@export var fade_in_time:float = 10
@export var stay_time:float = 1
@export var fade_out_time:float = 1
@export var sleep_after_time:float = 0
@export var fade_elements:Array[RichTextLabel]
signal faded_out

var started:bool = false
var lifetime:float
var arr_size:int
var fade_out_buffer:float

func _ready() -> void:
	arr_size = fade_elements.size()
	lifetime = 0
	fade_out_buffer = fade_out_time
	for i:int in arr_size:
		fade_elements[i].self_modulate.a = 0

func start() -> void:
	started = true

func _process(delta: float) -> void:
	if started:
		lifetime += delta
		if lifetime <= fade_in_time:
			var progress:float = clamp(lifetime / fade_in_time, 0, 1) * arr_size
			for i:int in arr_size:
				var alpha:float = clamp(progress - i, 0, 1)
				fade_elements[i].self_modulate.a = alpha
		elif stay_time > 0:
			stay_time -= delta
		elif fade_out_buffer >= 0:
			fade_out_buffer -= delta
			modulate.a = fade_out_buffer / fade_out_time
		elif sleep_after_time > 0:
			sleep_after_time -= delta
		else:
			faded_out.emit()
			free()
