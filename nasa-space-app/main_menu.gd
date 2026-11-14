extends Control

@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	start_button.grab_focus()
	
func _on_start_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finishedget_tree().change_scene_to_file("res://scenes/tutorial.tscn")
