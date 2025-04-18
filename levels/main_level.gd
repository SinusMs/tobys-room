extends Node2D

var rauchwolke_scene : PackedScene = preload("res://entities/rauchwolke_cpu_particles.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func item_play_sound(string : String = "") -> void:
	if Utils.currently_selected_item == null:
		return
	$AudioStreamPlayer.stream = Utils.currently_selected_item.sound
	$AudioStreamPlayer.play()

func _spawn_children(item : ItemBase) -> bool:
	var children : Dictionary = item.children
	if children.size() == 0:
		return false
	for child : PackedScene in children:
		var child_scene : ItemBase = child.instantiate()
		child_scene.position = item.position + children[child]
		%ItemContainer.add_child(child_scene)
	return true

func _spawn_particles(item : ItemBase) -> void:
	var rauchwolke: CPUParticles2D = rauchwolke_scene.instantiate()
	rauchwolke.position = item.position + item.mittelpunkt
	rauchwolke.emitting = true
	%ParticleContainer.add_child(rauchwolke)

func cleanup() -> void:
	Utils.currently_selected_item = null
	$Menu.change_item("")

func end_this() -> void:
	for i in 100:
		await get_tree().create_timer(.1).timeout
		Utils.found_items += 1
		$CanvasLayer._on_item_picked_up(null)
	get_tree().quit()
