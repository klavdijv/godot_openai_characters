class_name AIFunctionGroup
extends Node

func to_json() -> Array[Dictionary]:
	var json_data: Array[Dictionary] = []
	for child in get_children():
		if child is AIFunctions:
			json_data.append_array(child.to_json())
	return json_data
