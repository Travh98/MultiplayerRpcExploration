extends CharacterBody2D
class_name PlayerCharacter

const SPEED = 300.0
@onready var name_tag = $NameTag

func _enter_tree():
	# Server and Clients all agree that multiplayer authority belongs to this name/peer_id
	set_multiplayer_authority(str(name).to_int())

func _ready():
	# Only allow the authority of this node to run functions like this
	if not is_multiplayer_authority(): return
	
	# Set your nametag as your name
	name_tag.text = name
	
	$Camera2D.make_current()

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	
	var direction := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"), 
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if direction:
		velocity = direction.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
