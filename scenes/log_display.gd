extends Control
class_name LogDisplay

@onready var log_label = $MarginContainer/HBoxContainer/VBoxContainer/LogLabel

func add_log(msg: String):
	log_label.text = log_label.text + "\n" + msg
