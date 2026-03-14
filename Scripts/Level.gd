# ini adalah script yang mengatur scene level (Level001, Level002, dan seterusnya).

extends Node

# scene selanjutnya
export var next_scene_path = "res://Scenes/End.tscn"

# scene game over
export var game_over_scene_path = "res://Scenes/GameOver.tscn"

# flip degree yang menyebabkan game over
export var game_over_flip_degree = 80

# flip time yang menyebabkan game over
export var flip_time = 5

export var next_scene_target_group = "player"

# node tempat men-spawn mobil
onready var spawn = get_node("Spawn")

var player_car

var flip_timer

func _ready():
	# sembunyikan kursor mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# flip_timer = get_tree().create_timer(flip_time)
	
	# ambil mobil terpilih
	var chosen_car = Globals.chosen_car
	print(chosen_car)
	
	# instantiate mobil terpilih
	var chosen_car_ld = load("res://Prefabs/" + chosen_car + ".tscn")
	
	var chosen_car_instance = chosen_car_ld.instance()
	chosen_car_instance.global_transform = spawn.global_transform
	
	# masukkan mobil ke group bernama "player"
	chosen_car_instance.add_to_group("player")
	
	add_child(chosen_car_instance)
	
	player_car = get_node(chosen_car)
	
func _input(_event):
	# untuk tampilkan dan sembunyikan kursor mouse
	if _event is InputEventKey and _event.pressed and _event.scancode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if _event is InputEventMouseButton and _event.pressed and _event.button_index == 1:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# kalau mobil belum dipilih, jangan diteruskan prosedur ini.
	if player_car == null:
		return
		
	# cek mobil flipped
	var try = player_car.transform.basis.y
	
	if abs(try.angle_to(Vector3.UP)) > deg2rad(game_over_flip_degree):
		flip_timer = get_tree().create_timer(flip_time)
		yield(flip_timer,"timeout")
		print("flipped")
		
		# game over
		get_tree().change_scene(game_over_scene_path)

# saat mobil memasuki garis finish
func _on_Finish_body_entered(body):
	# maka menang
	if body.get_groups().has(next_scene_target_group):
		print("finished")
		get_tree().change_scene(next_scene_path)

# saat mobil terjatuh
func _on_Fall_body_entered(body):
	# maka game over
	if body.get_groups().has(next_scene_target_group):
		print("fall")
		get_tree().change_scene(game_over_scene_path)
