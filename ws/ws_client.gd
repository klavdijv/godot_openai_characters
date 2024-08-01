class_name WSClient
extends Node

@export var websocket_url: String = 'ws://localhost:8000/ws'
@export var handler: String

var socket: WebSocketPeer
var _json := JSON.new()
var _connected := false

signal got_data(data: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_to_websocket()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	socket.poll()
	
	var state := socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		_connected = true
		while socket.get_available_packet_count():
			var data: Dictionary = _json.parse_string(socket.get_packet().get_string_from_utf8())
			got_data.emit(data)
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		_connected = false
		set_process(false)


func send_json(data: Dictionary) -> void:
	if _connected:
		data['handler'] = handler
		var message := _json.stringify(data)
		socket.send_text(message)
	else:
		print('not connected')


func connect_to_websocket() -> void:
	if _connected:
		return

	socket = WebSocketPeer.new()
	var err := socket.connect_to_url(websocket_url)
	if err != OK:
		print('error connecting to web socket')
		set_process(false)
	set_process(true)
