extends Control
class_name ChatUI

@onready var chat_log = $MarginContainer/HBoxContainer/VBoxContainer/ChatLogLabel
@onready var chat_line_edit = $MarginContainer/HBoxContainer/VBoxContainer/ChatLineEdit

func _input(_event):
	if Input.is_action_just_pressed("enter"):
		write_msg()

func write_msg():
	if !chat_line_edit.text.is_empty():
		receive_msg.rpc(str(multiplayer.get_unique_id()) + ": " + chat_line_edit.text)
		chat_line_edit.text = ""

# call_local allows the server to run the rpc function on itself and also on clients
# any_peer allows the clients to run the rpc function on the server
# reliable means the network packets will not be lost, packets will be sent until received and acknowledged
# send the rpc on rpc channel 1 (to keep message traffic off of the standard movement traffic)
@rpc("call_local", "any_peer", "reliable", 1)
func receive_msg(msg: String):
	chat_log.text = chat_log.text + "\n" + msg
