extends Panel


var value setget set_value, get_value

func get_value():
	return value

func set_value(x):
	value = x
	$Label.text = str(value)

func _ready():
	self.value = [2,4][randi()%2]
	$AnimationPlayer.play("spawn")


