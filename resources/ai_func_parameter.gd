class_name AIFuncParameter
extends Resource

@export var parameter_name: String
@export var parameter_type: String
@export_multiline var parameter_description: String
@export var parameter_enum: Array[String]
@export var required: bool = false

func to_dict() -> Dictionary:
	var _dict := {'type': parameter_type, 'description': parameter_description}
	if parameter_enum:
		_dict['enum'] = parameter_enum
	return _dict
