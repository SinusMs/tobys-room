extends Panel
var next_pos: Vector2 = Vector2(0,0)

func _ready() -> void:
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	SignalBus.toggle_achievements.connect(_on_toggle_achievements)
	

func _on_exit_overview_button_down() -> void:
	SignalBus.toggle_achievements.emit()


func _on_item_picked_up(item: ItemBase) -> void:
	item.position = Vector2(0,0)
	if item.type == Utils.TYPE.STORY or item.type == Utils.TYPE.EGG:
		$TextureRect/ScrollContainer/GridContainer.add_child(item)

	
	
func _on_toggle_achievements() -> void:
	if $".".visible:
		$"AnimationPlayer".play("hide")
		await $"AnimationPlayer".animation_finished
		$".".hide()
	else:
		$".".show()
		$"AnimationPlayer".play("show")
