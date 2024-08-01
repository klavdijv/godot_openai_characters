class_name AIFunction
extends Resource

@export var function_name: String
@export_multiline var description: String
@export var parameters: Array[AIFuncParameter]

func to_json() -> Dictionary:
	var json_data := {}
	json_data['type'] = 'function'
	json_data['function'] = get_function_def()
	return json_data

func get_function_def() -> Dictionary:
	var func_def := {}
	func_def['name'] = function_name
	func_def['description'] = description
	func_def['parameters'] = get_parameters_def()
	return func_def
	
func get_parameters_def() -> Dictionary:
	var param_def := {'type': 'object'}
	param_def['properties'] = get_properties_def()
	var required_parameters = get_required_parameters()
	if required_parameters:
		param_def['required'] = required_parameters
	return param_def

func get_properties_def() -> Dictionary:
	var prop_def := {}
	for param: AIFuncParameter in parameters:
		prop_def[param.parameter_name] = param.to_dict()
	return prop_def

func get_required_parameters() -> Array[String]:
	var req_param: Array[String] = []
	for param: AIFuncParameter in parameters:
		if param.required:
			req_param.append(param.parameter_name)
	return req_param
