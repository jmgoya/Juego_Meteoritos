#BaseEnemiga.gd
class_name BaseEnemiga
extends Node2D

## Atributos Export
export var hitpoints:float = 100.0

## Atributos Onready
onready var impacto_sfx:AudioStreamPlayer2D = $ImpactosSFX

## Atributos
var esta_destruida:bool = false

## Metodos
func _ready() -> void:
	$AnimationPlayer.play(elegir_animacion_aleatoria())

## Metodos Custom
func elegir_animacion_aleatoria() -> String:
	randomize()
	var num_anim:int = $AnimationPlayer.get_animation_list().size() - 1
	var indice_anim_aleatoria:int = randi() % num_anim + 1
	var lista_animacion:Array = $AnimationPlayer.get_animation_list()
	
	return lista_animacion[indice_anim_aleatoria]

func recibir_danio(danio:float) -> void:
	hitpoints -= danio
	if hitpoints == 10:
		 print ("Daño a la base  ", hitpoints)
	if hitpoints <= 0 and not esta_destruida:
		esta_destruida  = true
		destruir_me()
	impacto_sfx.play()

func destruir_me() -> void:
	var posiciones = [
		$Sprites/SpaceStation017.global_position,
		$Sprites/SpaceStation024.global_position,
		$Sprites/SpaceStation028.global_position,
		$Sprites/SpaceStation029.global_position
	]
	Eventos.emit_signal("base_destruida", posiciones )
	queue_free()

## Señales Internas
func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()