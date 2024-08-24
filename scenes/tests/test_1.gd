extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test1()
	print('ready')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func test1() -> void:
	test2()
	print('test 1 1')
	
func test2() -> void:
	await get_tree().create_timer(1.0).timeout
	print('test 2 1')
	await get_tree().create_timer(0.5).timeout
	print('test 2 2 ')
