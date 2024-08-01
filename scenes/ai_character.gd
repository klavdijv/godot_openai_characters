extends Node

@export var character_name: String
@export_multiline var character_description: String

var system_prompt: Dictionary
var tools: Array[Dictionary]

signal got_text(text: String)
signal function_called(function_name: String, arguments: Dictionary)
signal stream_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var character_prompt := 'You are a RPG character.\n'
	character_prompt += 'You must not reveal this is a game nor that you are a game character\n'
	character_prompt += 'Your name is ' + character_name + '.\n'
	character_prompt += character_description
	system_prompt = {'role': 'system', 'content': character_prompt}
	#tools = %AIFunctions.to_json()
	tools = get_tools()
	print(tools)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func send_message(message: String, use_tools: bool=true) -> void:
	var messages: Array[Dictionary] = [system_prompt]
	messages.append({'role': 'user', 'content': message})
	
	var json_data := {'character_name': character_name, 'messages': messages}
	#var tools = %AIFunctions.to_json()
	if tools and use_tools:
		json_data['tools'] = tools
	%WSClient.send_json(json_data)

func _on_ws_client_got_data(data: Dictionary) -> void:
	if 'message' in data:
		got_text.emit(data['message'])
	elif 'function' in data:
		function_called.emit(data['function'], JSON.parse_string(data['arguments']))
	elif 'finished' in data:
		stream_finished.emit()
		
func get_tools() -> Array[Dictionary]:
	var _tools: Array[Dictionary] = []
	for child in get_children():
		if child is AIFunctions or child is AIFunctionGroup:
			_tools.append_array(child.to_json())
	return _tools
