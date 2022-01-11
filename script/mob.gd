extends KinematicBody

export var back=3
export var atkspeed=1
export var movespeed=3
onready var knightHP=get_node("/root/Main/knightHP")
var aniflag=false						#アニメ再生フラグ
var atkarea=false						#攻撃範囲に居座っているかどうか
var enarea=false
var stunflag=false						#スタンしているかどうか
var anipl								#アニメプレイヤーを多く呼び出すため格納させる
var knightnode


func _ready():
	anipl=get_node("AnimationPlayer")
	knightnode=get_node("/root/Main/knight/")


func _process(delta):
			
	if aniflag==false:
		
		if atkarea==true&&stunflag==false:
			attack()
		elif enarea==true:
			look_at(knightnode.get_translation() ,Vector3.UP)
			rotation_degrees.y-=180			#初期位置との差異をなくす
			move_and_slide((knightnode.get_translation()-translation).normalized()*movespeed, Vector3.UP)
			run()
		else:
			idle()						#ループしてるから一度呼び出せばいい
			
		
#再生中のアニメーションが終了したら
	if anipl.current_animation_position>=anipl.current_animation_length:
		aniflag=false
		stunflag=false
		anipl.playback_speed=1
	pass


#攻撃範囲に入ったら
func _on_attack_area_body_entered(body):
	if body.name=="knight":
		atkarea=true
		enarea=false
		#attack()
	pass # Replace with function body.

#攻撃範囲を出たら
func _on_attack_area_body_exited(body):
	if body.name=="knight":
		atkarea=false
		enarea=true
	pass # Replace with function body.
		
#認識エリアに入ったら
func _on_en_body_entered(body):
	if body.name=="knight":
		enarea=true
	pass # Replace with function body.
		
#認識エリアを出たら
func _on_en_body_exited(body):
	if body.name=="knight":
		enarea=false
	pass # Replace with function body.
		
#剣が相手にに入ったら相手が被弾モーション
func _on_Area_body_entered(body):
	if body.name=="knight":
		body.uke()
		knightHP.value-=30
	pass # Replace with function body.
	
		
func idle():
	anipl.playback_speed=0.4
	anipl.play("fight")
	$run.stop()
	#aniflag=true			
	
func run():
	anipl.playback_speed=1
	anipl.play("SwordAndShieldRun")
	if $run.playing!=true:
		$run.play()
	
func attack():
	anipl.playback_speed=atkspeed
	anipl.play("SwordAndShieldSlash_2")
	aniflag=true				

func uke():
	var n=rand_range(0,100)					#半分の確率で被弾モーションを取らない
	if n<=50:
		if stunflag==false:					#スタンしてないなら
			anipl.playback_speed=1.2
			anipl.play("uke")
			aniflag=true

func stun():
	aniflag=true
	stunflag=true
	anipl.play("stun")
	$shield2.play()
	$Skeleton/BoneAttachment/sword/CollisionShape.disabled=true

