extends Label

var time : float

func _process(delta):
	time += delta
	text = "Time: " + str(snappedf(time, 0.01))
