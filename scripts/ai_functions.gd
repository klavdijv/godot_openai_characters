class_name AIFunctions
extends Node

@export var functions: Array[AIFunction]

func to_json() -> Array[Dictionary]:
	var json_data: Array[Dictionary] = []
	for function: AIFunction in functions:
		json_data.append(function.to_json())
	return json_data
