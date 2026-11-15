extends CanvasLayer

const CHAR_READ_RATE = 0.05

@onready var textbox_container = $TextboxContainer
@onready var tb_name = $TextboxContainer/MarginContainer/VBoxContainer/Name
@onready var tb_text = $TextboxContainer/MarginContainer/VBoxContainer/HBoxContainer/Text
@onready var tb_end = $TextboxContainer/MarginContainer/VBoxContainer/End

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var dialogue_data = {}
var current_key = "line_1" # The starting key defined in your JSON
var tween: Tween

func _ready():
	print("Starting state: State.READY")
	hide_textbox()
	load_dialogue("res://Text/sample.json")
	
	# Start the first line immediately if data loaded successfully
	if not dialogue_data.is_empty():
		display_text()

func load_dialogue(path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json_string = file.get_as_text()
		var data = JSON.parse_string(json_string)
		
		if data is Dictionary:
			dialogue_data = data
			print("Successfully loaded dialogue data!")
		else:
			print("Error: JSON failed to parse or root is not a dictionary.")
	else:
		print("Error: Dialogue file not found at ", path)

func _process(delta):
	match current_state:
		State.READY:
			pass
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				tb_text.visible_ratio = 1.0
				if tween:
					tween.kill()
				tb_end.text = "[ENTER]"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				advance_dialogue()

func advance_dialogue():
	var current_entry = dialogue_data.get(current_key, {})
	var next_key = current_entry.get("next", "")
	
	if next_key != "" and dialogue_data.has(next_key):
		current_key = next_key
		display_text()
	else:
		hide_textbox()
		change_state(State.READY)

func hide_textbox():
	tb_name.text = ""
	tb_text.text = ""
	tb_end.text = ""
	textbox_container.hide()

func show_textbox():
	textbox_container.show()

func display_text():
	var current_entry = dialogue_data.get(current_key, {})
	tb_name.text = current_entry.get("name", "")
	var next_text = current_entry.get("text", "")
	
	tb_text.text = next_text
	tb_text.visible_ratio = 0.0
	tb_end.text = ""
	change_state(State.READING)
	show_textbox()
	
	tween = create_tween()	
	tween.tween_property(tb_text, "visible_ratio", 1.0, len(next_text) * CHAR_READ_RATE) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN_OUT)	
		
	tween.tween_callback(func():
		tb_end.text = "[ENTER]"
		change_state(State.FINISHED)
	)

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing state to: State.READY")
		State.READING:
			print("Changing state to: State.READING")
		State.FINISHED:
			print("Changing state to: State.FINISHED")
