extends Camera

export var  Xsensi=0.001				#マウス感度
export var  Ysensi=0.1				#マウス感度
var mourel=Vector2.ZERO				#マウスのrelative(相対)はXYだけで二次元
var mousex=0.0
var mousey=0.0
var camerapos
var raynode


func _input(event):
	if event is InputEventMouseMotion:
		mourel += event.relative
	pass
	

func _ready():
	camerapos=get_translation()
	raynode=get_node("/root/Main/knight/RayCast/")

func _physics_process(delta):
	mousex=mourel.x*Xsensi
	mousey-=mourel.y*Ysensi
	get_parent().global_rotate(Vector3.UP,-mousex)
	#global_rotate(Vector3.LEFT, -clamp(mourel.y*Ysensi,-PI/90,PI/90))
	#get_parent().rotation_degrees.y=clamp(mousex,-90,90)
	#rotation_degrees.y+=180
	rotation_degrees.x=clamp(mousey,-30,-10)
	mourel=Vector2.ZERO
	
	if raynode.is_colliding():
		global_transform.origin =raynode.get_collision_point() - global_transform.basis.z
	else:
		translation = camerapos
	pass

#ローカルではなくグローバルなのはローカルの値を無視して無理やり回転できるから
