extends Control

@onready var play_button = $PlayButton
@onready var text_edit: TextEdit = $TextEdit
@onready var back_button: Button = $BackButton


func _ready() -> void:
	play_button.pressed.connect(_play_pressed)
	back_button.connect("pressed", _back_pressed)


func _back_pressed():
	Helpers.set_scene("TITLE")


func _play_pressed():
	Game.pr2_level_id = text_edit.text
	Helpers.set_scene("GAME")