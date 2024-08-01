extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_send_button_pressed() -> void:
	if %MessageEdit.text == '':
		return
	$CedricTheButler.send_message(%MessageEdit.text)
	%SendButton.disabled = true


func _on_ws_client_got_data(data: Dictionary) -> void:
	pass


func _on_cedric_the_butler_got_text(text: String) -> void:
	%MessageOutput.text += text


func _on_cedric_the_butler_stream_finished() -> void:
	%SendButton.disabled = false
	%MessageEdit.text = ''
	%MessageOutput.text += '\n'


func _on_cedric_the_butler_function_called(function_name: String, arguments: Dictionary) -> void:
	prints(function_name, arguments)
	if function_name == 'open_door':
		open_door(arguments['door_name'])
	
func open_door(door_name: String) -> void:
	$CedricTheButler.send_message('notify me that the %s door was open' % door_name, false)
