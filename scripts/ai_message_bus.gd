extends Node

signal tool_call_finished(call_id: String, result: String)

func send_tool_call_result(call_id: String, result: String) -> void:
	tool_call_finished.emit.call_deferred(call_id, result)
