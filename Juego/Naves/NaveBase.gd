#NaveBase.gd
class_name NaveBase
extends RigidBody2D

## Enums (enumerables)
enum ESTADOS {SPAWN, VIVO, INVENCIBLE, MUERTO}

## Atributos Export
export var hitpoints_total:float = 100

## Atributos
var estado_actual:int = ESTADOS.SPAWN
var hitpoints:float = 0

## Atributos onready
onready var canion:Canion = $Canion
onready var colisionador:CollisionShape2D = $CollisionShape2D
onready var impacto_sfx:AudioStreamPlayer = $ImpactosSFX
onready var barra_salud:ProgressBar = $BarraSalud
onready var tiempo_reparacion:Timer = $TiempoReparacion

#JMG
onready var animacion:AnimationPlayer = $AnimationPlayer

## Metodos
func _ready() -> void:
	hitpoints = hitpoints_total
	barra_salud.set_valores(hitpoints)
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
	barra_salud.controlar_barra(hitpoints, true)
	if name == "Player":
		tiempo_reparacion.stop()
		tiempo_reparacion.wait_time = 5
		tiempo_reparacion.start()

func reparar() -> void:
	tiempo_reparacion.stop()
	if hitpoints >= hitpoints_total - 4:
		return
	hitpoints += 4
	tiempo_reparacion.wait_time = 1
	tiempo_reparacion.start()
	barra_salud.controlar_barra(hitpoints, true)

## señales internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		cambiar_estado(ESTADOS.VIVO)

func _on_body_entered(body: Node) -> void:
	if body is Meteorito or (body.name == "Player"):
		body.destruir()
		destruir()

func _on_TiempoReparacion_timeout() -> void:
	reparar()
