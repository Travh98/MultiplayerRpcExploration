extends Node
class_name GlobalWorldRoot

# Multiplayer Settings
const PORT = 25026
const Player = preload("res://scenes/player_character.tscn")

# Components
@onready var main_menu: MainMenu = $CanvasLayer/MainMenu
@onready var log_display: LogDisplay = $CanvasLayer/LogDisplay
@onready var chat_ui: ChatUI = $CanvasLayer/ChatUI

const quick_quit_game: bool = false

func _ready():
	main_menu.host_button.pressed.connect(on_host_button_pressed)
	main_menu.join_button.pressed.connect(on_join_button_pressed)

func on_host_button_pressed():
	main_menu.hide()
	log_display.add_log("Starting Host")
	setup_network(true)
	# Add a character for the Host to own and control
	add_player_character(multiplayer.get_unique_id())

func on_join_button_pressed():
	main_menu.hide()
	log_display.add_log("Joining Server as Client")
	setup_network(false)

func setup_network(is_host: bool):
	var enet_peer = ENetMultiplayerPeer.new()
	if is_host:
		print("Setting up server as host")
		enet_peer.create_server(PORT)
		
		# Setup signal-slot functions to handle when Players join
		multiplayer.peer_connected.connect(on_peer_connected)
		multiplayer.peer_disconnected.connect(on_peer_disconnected)
		upnp_setup()
	else:
		# If Player hasn't entered an IP Address, join localhost (LAN Party)
		var join_address: String = "localhost"
		if !main_menu.address_entry.text.is_empty():
			join_address = main_menu.address_entry.text
		
		print("Joining as client to ", join_address)
		enet_peer.create_client(join_address, PORT)
	multiplayer.multiplayer_peer = enet_peer
	log_display.add_log("My multiplayer ID: " + str(multiplayer.get_unique_id()))

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
	"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Port Mapping Failed! Error %s" % map_result)
	
	#print("Success! Server listening on Address %s" % upnp.query_external_address()) 

func on_peer_connected(peer_id: int):
	print("Peer connected: ", peer_id )
	add_player_character(peer_id)

func on_peer_disconnected(peer_id: int):
	remove_player_character(peer_id)

func add_player_character(peer_id):
	log_display.add_log("Host is creating player character for peer: %s" % str(peer_id))
	
	# Spawn a new character for this player to control
	var player_character = Player.instantiate()
	
	# Set the player character's name to the peer_id of the Player who owns it
	player_character.name = str(peer_id)
	
	add_child(player_character)

func remove_player_character(peer_id):
	log_display.add_log("Despawning player character for peer: %s" % str(peer_id))
	# Find and despawn the character that peer is controlling
	var player_character = get_node_or_null(str(peer_id))
	if player_character:
		player_character.queue_free()

func _input(_event):
	if quick_quit_game:
		# Quit game when escape is pressed
		if Input.is_action_pressed("escape"):
			get_tree().quit()
