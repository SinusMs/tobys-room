extends TextureRect

signal finished

@export var fade_out: float = 1
@onready var fade_out_buffer:float = fade_out
var started: bool = false

func _on_start_screen_finished() -> void:
	started = true

func _process(delta: float) -> void:
	if started:
		fade_out_buffer -= delta
		self.self_modulate.a = clamp(fade_out_buffer / fade_out, 0, 1) 
		if fade_out <= 0:
			started = false
			finished.emit()
