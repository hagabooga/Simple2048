extends Panel

signal swipe
var node_scene = preload("res://Node.tscn")

var rows = 4
var cols = 4
var nodes = null
var nulls = 16

var score = 0 setget set_score, get_score
var best_score = 0 setget set_best


func set_score(x):
	score = x
	get_parent().get_child(2).get_child(1).text = "Score: " + str(score)

func get_score():
	return score

func set_best(x):
	best_score = x
	get_parent().get_child(2).get_child(2).text = "Best: " + str(best_score)

func swiped(dir):
	match dir:
		UP:
			go_up()
		DOWN:
			go_down()
		LEFT:
			go_left()
		RIGHT:
			go_right()

func _ready():
	connect("swipe", self, "swiped")
	reset()

enum {UP,DOWN,LEFT,RIGHT}

func go_up():
	go_direction(-4, UP, range(0, nodes.size()))
func go_down():
	go_direction(4, DOWN, range(nodes.size() - 1, -1, -1))
func go_left():
	go_direction(-1, LEFT, range(0,13,4) + range(1,14,4) + range(2,15,4) + range(3,16,4))
func go_right():
	go_direction(1, RIGHT, range(3,16,4) + range(2,15,4)  + range(1,14,4) + range(0,13,4))
	
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		go_up()
	elif Input.is_action_just_pressed("ui_down"):
		go_down()
	elif Input.is_action_just_pressed("ui_left"):
		go_left()
	elif Input.is_action_just_pressed("ui_right"):
		go_right()
	elif Input.is_action_just_pressed("reset"):
		reset()

func reset():
	self.score = 0
	self.best_score = 0
	load_game()
	if nodes != null:
		for node in nodes:
			if node != null:
				node.queue_free()
	randomize()
	nodes = []
	for _i in range(rows*cols):
		nodes.append(null)
	nulls = 16
	spawn_random_node()


func delete_node(index):
	nodes[index].queue_free()
	nodes[index] = null
	nulls += 1


func shift_node(index, check_index, check_index_offset):
	var panel = $GridContainer.get_child(index)
	var node_obj = panel.get_child(0)
	panel.remove_child(node_obj)
	$GridContainer.get_child(check_index - check_index_offset).add_child(node_obj)
	nodes[index] = null
	nodes[check_index - check_index_offset] = node_obj



func go_direction(check_index_offset, stop, order):
	var spawn = false
	for index in order:
		var node = nodes[index]
		if node != null:
			var check_index = index
			while true:
				check_index += check_index_offset
				var boolean_check
				match stop:
					UP:
						boolean_check = check_index < 0
					DOWN:
						boolean_check = check_index > 15
					LEFT:
						boolean_check = (check_index + 1) % 4 == 0
					RIGHT:
						boolean_check = (check_index - 4) % 4 == 0
				if boolean_check:
					if nodes[check_index - check_index_offset] == null:
						shift_node(index, check_index, check_index_offset)
						spawn = true
					break
				var check = nodes[check_index]
				if check == null:
					continue
				if check != null:
					# same
					if node.value == check.value:
						check.value *= 2
						self.score += check.value
						if score > best_score:
							self.best_score = score
							save_game()
							print("WOW")
						delete_node(index)
						spawn = true
					else:
						if index != check_index - check_index_offset:
							shift_node(index, check_index, check_index_offset)
							spawn = true
					break
	if spawn:
		spawn_random_node()



func spawn_random_node():
	if nulls == 0:
		return
	var try_index = randi() % nodes.size()
	while true:
		if nodes[try_index] == null:
			var node = node_scene.instance()
			nodes[try_index] = node
			$GridContainer.get_child(try_index).add_child(node)
			nulls -= 1
			break
		try_index = randi() % nodes.size()


func save_game():
	var save_dict = {
		"best": score
	}
	var save_file = File.new()
	save_file.open("user://savegame.save", File.WRITE)
	save_file.store_line(to_json(save_dict))
	save_file.close()



func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		print("no save")
		return # Error! We don't have a save to load.

	save_game.open("user://savegame.save", File.READ)
	var current_line = parse_json(save_game.get_line())
	while current_line != null:
		self.best_score = current_line["best"]
		current_line = parse_json(save_game.get_line())

	save_game.close()


func _on_Button_pressed():
	pass # Replace with function body.


func press_why():
	get_parent().get_child(2).get_child(7).visible = true
	


var swipe_start = null
var minimum_drag = 100

func _input(event):
	if event is InputEventScreenDrag:
		_calculate_swipe(event)
		
func _calculate_swipe(s):
	var swipe = s.relative
	print(swipe)
	if abs(swipe.x) > abs(swipe.y):
		if abs(swipe.x) > minimum_drag:
			if swipe.x > 0:
				emit_signal("swipe", RIGHT)
			else:
				emit_signal("swipe", LEFT)
	else:
		if abs(swipe.y) > minimum_drag:
			if swipe.y < 0:
				emit_signal("swipe", UP)
			else:
				emit_signal("swipe", DOWN)


