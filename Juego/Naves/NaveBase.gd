#NaveBase.gd
class_name NaveBase
extends RigidBody2D

## Enums (enumerables)
enum ESTADOS {SPAWN, VIVO, INVENCIBLE, MUERTO}

## Atributos Export
export var hitpoints:float = 100

## Atributos
var estado_actual:int = ESTADOS.SPAWN

## Atributos onready
onready var canion:Canion = $Canion
onready var colisionador:CollisionShape2D = $CollisionShape2D
onready var impacto_sfx:AudioStreamPlayer = $ImpactosSFX

#JMG
onready var animacion:AnimationPlayer = $AnimationPlayer

## Metodos
func _ready() -> void:
	cambiar_estado(estado_actual)

## Metodos Custom
func destruir() -> void:
	cambiar_estado(ESTADOS.MUERTO)

func cambiar_estado(nuevo_estado: int) -> void:
	match nuevo_estado:
		ESTADOS.SPAWN:
			colisionador.set_deferred("disabled", true)
			canion.set_puede_disparar(false)
		ESTADOS.VIVO:
			colisionador.set_deferred("disabled", false)
			canion.set_puede_disparar(true)
		ESTADOS.MUERTO:
			colisionador.set_deferred("disabled", true)
			canion.set_puede_disparar(false)
			Eventos.emit_signal("nave_destruida", self, global_position, 2)
			queue_free()
		ESTADOS.INVENCIBLE:
			colisionador.set_deferred("disabled", true)
		_:
			printerr("Error cambiando los estados")
	estado_actual = nuevo_estado

func recibir_danio(intensidad_danio:float) -> void:
	hitpoints -= intensidad_danio
	if hitpoints <= 0:
		destruir()
	#animacion.play("impacto")
	impacto_sfx.play()

## señales internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		cambiar_estado(ESTADOS.VIVO)

func _on_body_entered(body: Node) -> void:
	if body is Meteorito:
		body.destruir()
		destruir()
