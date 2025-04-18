class_name ItemBase

extends Control

@export var item_name: String = ""
@export_multiline var description: String = ""
@export var labelText: String = "Put away"
@export var type := Utils.TYPE.FILLER
@export var children : Dictionary[PackedScene, Vector2]
@export var sound : AudioStream
@export var dependencies: Array[ItemBase]
var mittelpunkt : Vector2
var isHighlighted : bool = false
var anim : AnimationPlayer

func _ready() -> void:
	set_highlight_colors()
	$Highlight.hide()
	mittelpunkt = %Mittelpunkt.position
	anim = $AnimationPlayer
	#ausdehnung der parent control node setzen für scrollcontainer
	$".".custom_minimum_size = 2*Vector2($Sprite.texture.get_width(), $Sprite.texture.get_height())

func showHighlight(_show: bool) -> void:
	if _show:
		$Highlight.show()
	else:
		$Highlight.hide()

func isAllNull(list: Array[ItemBase]) -> bool:
	for item: ItemBase in list:
		if item != null:
			return false
	return true

func _on_gui_input(event:InputEvent) -> void:
	# Deactivate input check if dependencies are still alive
	if !isAllNull(dependencies):
		return

	# Logic to change item highlighted by hover
	if Geometry2D.is_point_in_polygon(event.position, $CollisionPolygon2D.polygon):
		# Unhighlight last hovered item
		if Utils.currently_hovered_item != null && Utils.currently_hovered_item != self && Utils.currently_hovered_item != Utils.currently_selected_item:
			Utils.currently_hovered_item.call_deferred("showHighlight", false)

		# Highlight currently hovered item
		Utils.currently_hovered_item = self
		showHighlight(true)
	else:
		# Unhighlight item if no longer hovered, unless highlighted by selecting
		if !isHighlighted:
			if Utils.currently_hovered_item != null && Utils.currently_hovered_item != Utils.currently_selected_item:
				Utils.currently_hovered_item.showHighlight(false)
				Utils.currently_hovered_item = null

	# Logic to change item highlighted by click
	if Geometry2D.is_point_in_polygon(event.position, $CollisionPolygon2D.polygon):
		if event.is_action_pressed("left_click"):
			# Unhighlight last clicked item
			if Utils.currently_selected_item != null:
				Utils.currently_selected_item.call_deferred("showHighlight", false)
				Utils.currently_selected_item.set.call_deferred("isHighlighted", false)
				
			# highlight clicked item
			Utils.currently_selected_item = self
			SignalBus.item_changed.emit(labelText)
			isHighlighted = true

func set_highlight_colors():
	var shader = preload("res://entities/item_highlight.gdshader")
	$Highlight.material = ShaderMaterial.new()
	$Highlight.material.set("shader", shader)
	match type:
		Utils.TYPE.STORY:
			$Highlight.material.set("shader_parameter/color1", Color.from_string("df84a5", Color.FLORAL_WHITE))
			$Highlight.material.set("shader_parameter/color2", Color.from_string("e8c170", Color.FLORAL_WHITE))
			$Highlight.material.set("shader_parameter/speed", 5.0)
		Utils.TYPE.EGG:
			$Highlight.material.set("shader_parameter/color1", Color.from_string("a4dddb", Color.FLORAL_WHITE))
			$Highlight.material.set("shader_parameter/color2", Color.from_string("d0da91", Color.FLORAL_WHITE))
			$Highlight.material.set("shader_parameter/speed", 2.0)
		Utils.TYPE.FUNNY:
			$Highlight.material.set("shader_parameter/color1", Color.from_string("a4dddb", Color.FLORAL_WHITE))
			$Highlight.material.set("shader_parameter/color2", Color.from_string("d0da91", Color.FLORAL_WHITE))
			$Highlight.material.set("shader_parameter/speed", 2.0)
		_:
			$Highlight.material.set("shader_parameter/color1", Color.from_string("ebede9", Color.FLORAL_WHITE))
			$Highlight.material.set("shader_parameter/color2", Color.from_string("c7cfcc", Color.FLORAL_WHITE))
			$Highlight.material.set("shader_parameter/speed", 4.0)
