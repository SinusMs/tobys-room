extends Control

@export var start_on_ready:bool = false
var children:Array[Node]
var index:int = 0

signal finished

func _ready() -> void:
	if start_on_ready:
		start()

func start() -> void:
	$Background.show()
	children = $Elements.get_children()
	children[index].start()
	children[index].faded_out.connect(on_next_element)

func on_next_element() -> void:
	index += 1
	if index < children.size() and children[index].has_method("start"):
		children[index].start()
		children[index].faded_out.connect(on_next_element)
	else:
		finished.emit()


func _on_background_finished() -> void:
	self.hide()
