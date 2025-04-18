extends Control

@export var level : Node2D

var isShowingAchievements: bool = false

func _ready() -> void:
	SignalBus.item_changed.connect(change_item)
	SignalBus.toggle_achievements.connect(_on_toggle_achievements)
	
func change_item(newLabelText: String) -> void:
	if Utils.currently_selected_item == null:
		$"CanvasLayer/Panel/NameFrame/NameLabel".text = ""
		$"CanvasLayer/Panel/DescriptionFrame/ScrollContainer/DescriptionLabel".text = ""
		$"CanvasLayer/Panel/StashButton/RichTextLabel".text = newLabelText
		$"CanvasLayer/Panel/StashButton".hide()
	else:
		$"CanvasLayer/Panel/NameFrame/NameLabel".text = Utils.currently_selected_item.item_name
		$"CanvasLayer/Panel/DescriptionFrame/ScrollContainer/DescriptionLabel".text = Utils.currently_selected_item.description
		if !isShowingAchievements:
			$"CanvasLayer/Panel/StashButton".show()
		else:
			$"CanvasLayer/Panel/StashButton".hide()
		$"CanvasLayer/Panel/StashButton/RichTextLabel".text = newLabelText

func _on_stash_button_button_down() -> void:
	var picked_up_item : ItemBase
	if Utils.currently_selected_item == null:
		return
	
	if Utils.currently_selected_item.name == "Credits":
		level.end_this()

	#Play sound and particles
	level.item_play_sound("")
	level._spawn_particles(Utils.currently_selected_item)
	#play shrinking animation
	if Utils.currently_selected_item.type != Utils.TYPE.BOX:
		Utils.currently_selected_item.pivot_offset = Utils.currently_selected_item.mittelpunkt
		Utils.currently_selected_item.anim.play("hide")
		await get_tree().create_timer(.1).timeout
	
	#spawn children
	
	var has_children : bool = level._spawn_children(Utils.currently_selected_item)
	# Create copy of item to show in "Discovered"
	var item_base_scene = preload("res://entities/item_base.tscn")
	picked_up_item = item_base_scene.instantiate()
	picked_up_item.item_name = Utils.currently_selected_item.item_name
	picked_up_item.description = Utils.currently_selected_item.description
	picked_up_item.get_node("Sprite").texture = Utils.currently_selected_item.get_node("Sprite").texture
	picked_up_item.get_node("Highlight").texture = Utils.currently_selected_item.get_node("Highlight").texture
	picked_up_item.get_node("Schatten").hide()
	picked_up_item.get_node("CollisionPolygon2D").polygon = Utils.currently_selected_item.get_node("CollisionPolygon2D").polygon
	picked_up_item.type = Utils.currently_selected_item.type
	picked_up_item.sound = Utils.currently_selected_item.sound
	
	#  Utils.currently_selected_item.duplicate()
	if !has_children and Utils.currently_selected_item.type != Utils.TYPE.BOX:
		Utils.found_items += 1
	
	#delete item
	Utils.currently_selected_item.queue_free()
	Utils.currently_selected_item = null
	SignalBus.item_changed.emit("")
	if !has_children and picked_up_item.type != Utils.TYPE.BOX:
		SignalBus.item_picked_up.emit(picked_up_item)


func _on_background_gui_input(event:InputEvent) -> void:
	if Utils.currently_selected_item == null:
		return
	if event.is_action_pressed("left_click"):
		Utils.currently_selected_item.call_deferred("showHighlight", false)
		Utils.currently_selected_item = null
		SignalBus.item_changed.emit("")
		
		if Utils.currently_hovered_item != null:
			Utils.currently_hovered_item.set_deferred("isHighlighted", false)


func _on_achievement_button_button_down() -> void:
	SignalBus.toggle_achievements.emit()


func _on_toggle_achievements() -> void:
	Utils.currently_selected_item = null
	change_item("")
	$CanvasLayer/Panel/StashButton.hide()

	if !isShowingAchievements:
		isShowingAchievements = true
	else:
		isShowingAchievements = false
