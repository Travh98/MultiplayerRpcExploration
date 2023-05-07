extends Area2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("mouse_select"):
		for body in get_overlapping_bodies():
#			print("Clicked on body: ", body)
			if body is PlayerCharacter:
				var player_character: PlayerCharacter = body
				# Try kissing the player we found
				player_character.get_kissed.rpc()
