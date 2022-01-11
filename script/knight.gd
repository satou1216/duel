extends KinematicBody

export var speed = 10					#移動の速さ
export var back=10						#ノックバック距離倍率
onready var mobHP=get_node("/root/Main/mobHP")
onready var knightHP=get_node("/root/Main/knightHP")	#ガード判定のために
var actionflag=false					#行動フラグ、真の時は動けない
var guardflag=false						#盾を構えているかどうか
var swordflag=false						#剣を振るタイミング調整
var anipl								#アニメプレイヤーを多く呼び出すため格納させる


func _ready():
	anipl=get_node("AnimationPlayer")
	idle()
	pass # Replace with function body.


func _physics_process ( delta ):
	var direction = Vector3.ZERO

	if actionflag==false:					#行動中は何もできない
#プレイヤーの移動
		if Input.is_action_pressed("ui_right"):
			#direction.x -= 1
			direction-=get_child(0).global_transform.basis.x
			run()
		if Input.is_action_pressed("ui_left"):
			#direction.x += 1
			direction+=get_child(0).global_transform.basis.x
			run()
		if Input.is_action_pressed("ui_down"):
			#direction.z -= 1
			direction+=get_child(0).global_transform.basis.z
			run()
		if Input.is_action_pressed("ui_up"):
			#direction.z += 1
			direction-=get_child(0).global_transform.basis.z
			run()
			
		direction.y=0
		direction=direction.normalized()
		move_and_slide(direction*speed , Vector3.UP)


#プレイヤーの移動キーを放したらアイドル
		if Input.is_action_just_released("ui_right")||Input.is_action_just_released("ui_left")||Input.is_action_just_released("ui_down")||Input.is_action_just_released("ui_up"):
			idle()

#攻撃
		if Input.is_action_just_pressed("ui_select"):
			attack()
			
#ガード
		if Input.is_action_pressed("ui_accept"):
			guard()
#################この上まで行動中は不可#######################################################################################################################################################
#剣の振るタイミングに合わせてse
	if swordflag==true&&anipl.current_animation_position>=0.5&&anipl.current_animation_position<=0.7:
		$sword.play()

#再生中のアニメーションが終了したら
	if anipl.current_animation_position>=anipl.current_animation_length:
		$CollisionShape.disabled=false		#体の当たり判定有り
#ガード中なら
		if guardflag==true:
			if Input.is_action_just_released("ui_accept"):
				reguard()
		else:
			anipl.playback_speed=1
			actionflag=false
			swordflag=false
			$Skeleton/BoneAttachment2/Shield/CollisionShape.disabled=true
			idle()							#何もアニメーションが再生していないならアイドル
			
		
	pass

#剣が相手にに入ったら相手が被弾モーション
func _on_Area_body_entered(body):
	if body.name=="mob":
		body.uke()
		$uke.play()
		mobHP.value-=30
	pass # Replace with function body.

#盾の範囲に相手の剣が入ったら
func _on_Shield_area_entered(area):
	if area.name=="sword":
		area.get_child(0).disabled=true		#剣のコリジョンを消して体に当たらないようにする
#ジャスガ
		if guardflag==true&&(anipl.current_animation_position>=0.4&&anipl.current_animation_position<=0.6):
			$shield2.seek(0.23)
			area.get_parent().get_parent().get_parent().stun()
			knightHP.value+=30
		else:
#普通のガード			
			var mobpos=area.get_parent().get_parent().get_parent().get_translation()
			var knock=translation-mobpos	#プレイヤーの座標-mobの座標で飛ばす方向を決める
			move_and_slide(mobpos+(knock.normalized()*back) , Vector3.UP)	#飛ばす方向を正規化し好きな倍率を掛けてプレイヤーの座標に加算する
			$shield.play()
			knightHP.value-=10
	pass # Replace with function body.
	

#メソッド
func run():
	anipl.play("SwordAndShieldRun")
	if $run.playing!=true:
		$run.play()
		
func idle():
	anipl.play("Idle")
	$run.stop()
	
func attack():
	anipl.playback_speed=1.5
	anipl.play("SwordAndShieldSlash_2")
	actionflag=true
	swordflag=true

func uke():
	$CollisionShape.disabled=true			#コリジョンを消して無敵
	anipl.playback_speed=1.2
	anipl.play("uke")
	$uke.play()
	actionflag=true
	guardflag=false

func guard():
	actionflag=true
	guardflag=true
	anipl.playback_speed=2
	anipl.play("SwordAndShieldBlocking")
	
func reguard():
	anipl.playback_speed=1.5
	anipl.play("SwordAndShieldBlock")
	actionflag=true
	guardflag=false
	$Skeleton/BoneAttachment2/Shield/CollisionShape.disabled=true

func sestop():
	$sword.stop()
	$shield.stop()
	$run.stop()
