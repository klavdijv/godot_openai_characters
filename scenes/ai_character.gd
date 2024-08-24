extends Node

@export var character_name: String
@export_multiline var character_description: String

const FUNCTION_RESULT_ID: int = 0
const FUNCTION_RESULT_CONTENT: int = 1

var system_prompt: Dictionary
var tools: Array[Dictionary]
var tool_calls: Array[Dictionary]
var last_message: String

signal got_text(text: String)
signal function_called(function_name: String, arguments: Dictionary, call_id: String)
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
	last_message = message
	
	var json_data := {'character_name': character_name, 'messages': messages}
	#var tools = %AIFunctions.to_json()
	if tools and use_tools:
		json_data['tools'] = tools
	%WSClient.send_json(json_data)

func _on_ws_client_got_data(data: Dictionary) -> void:
	if 'message' in data:
		got_text.emit(data['message'])
	elif 'function' in data:
		#function_called.emit(data['function'], JSON.parse_string(data['arguments']))
		tool_calls.append(data)
	elif 'finished' in data:
		if tool_calls:
			process_tool_calls()
		else:
			stream_finished.emit()
		
func get_tools() -> Array[Dictionary]:
	var _tools: Array[Dictionary] = []
	for child in get_children():
		if child is AIFunctions or child is AIFunctionGroup:
			_tools.append_array(child.to_json())
	return _tools

func process_tool_calls() -> void:
	var results: Array[Dictionary]
	var call_ids: Array[String]
	var processed_ids: Array[String]
	
	for tool_call: Dictionary in tool_calls:
		call_ids.append(tool_call['id'])
		function_called.emit(tool_call['function'], JSON.parse_string(tool_call['arguments']), tool_call['id'])
	
	var counter := 0
	var number_of_calls = tool_calls.size()
	while counter < number_of_calls:
		var result = await AIMessageBus.tool_call_finished
		var tool_call_id: String = result[FUNCTION_RESULT_ID]
		if tool_call_id not in call_ids:
			continue
		var content: String = result[FUNCTION_RESULT_CONTENT]
		results.append({'role': 'tool', 'tool_call_id': tool_call_id, 'content': content})
		if tool_call_id not in processed_ids:
			processed_ids.append(tool_call_id)
			counter += 1
	
	_send_tool_call_results(results)

func _send_tool_call_results(results: Array[Dictionary]) -> void:
	var json_data: Dictionary = {'character_name': character_name,
								 'messages': _build_tool_call_response(results),
								 'tools': tools}
	%WSClient.send_json(json_data)
	tool_calls = []

func _build_tool_call_response(results: Array[Dictionary]) -> Array[Dictionary]:
	var messages: Array[Dictionary] = [system_prompt]
	messages.append({'role': 'user', 'content': last_message})
	messages.append({'role': 'assistant',
					 'content': null,
					 'tool_calls': _rebuild_tool_calls()})
	messages.append_array(results)
	return messages
	
func _rebuild_tool_calls() -> Array[Dictionary]:
	var calls_json: Array[Dictionary]
	for tool_call: Dictionary in tool_calls:
		calls_json.append({'id': tool_call['id'],
						   'function': {'arguments': tool_call['arguments'],
										'name': tool_call['function']},
						   'type': 'function'})
	return calls_json
