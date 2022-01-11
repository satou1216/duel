extends Spatial

var flag=false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused=false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flag==true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if Input.is_action_just_pressed("ui_cancel"):
		flag=!flag
		
	if Input.is_action_just_pressed("r"):
		get_tree().change_scene("res://scene/Main.tscn")
		
		
	if $knightHP.value<=0:
		$Label.show()
		get_tree().paused=true
		
	if $mobHP.value<=0:
		$Label2.show()
		get_tree().paused=true
	pass
	
