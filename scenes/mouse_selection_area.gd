extends Area2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("mouse_select"):
		for body in get_overlapping_bodies():
			print("Clicked on body: ", body)
			if body is PlayerCharacter:
				var player_character: PlayerCharacter = body
				# If this is the player we are controlling, you can't kiss yourself
#				if player_character.get_multiplayer_authority() == get_multiplayer_authority():
#					return
				# Give the other player a smooch
				player_character.get_kissed.rpc()
