# ini adalah script untuk mengatur scene StartMenu.tscn.

extends Control

# scene selanjutnya
export var next_scene_path = "res://Scenes/SelectCar.tscn"

func _ready():
	# tampilkan kursor mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Start_pressed():
	# ke scene selanjutnya
	get_tree().change_scene(next_scene_path)

func _on_Quit_pressed():
	# tutup game
	get_tree().quit()
