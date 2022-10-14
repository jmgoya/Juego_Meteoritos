#Player.gd
class_name Player

extends RigidBody2D

## Enums (enumerables)
enum ESTADOS {SPAWN, VIVO, INVENCIBLE, MUERTO}

## Atributos Export
export var potencia_motor:int = 20
export var potencia_rotacion:int = 280
export var estela_maxima:int = 150
export var hitpoints:float = 100

## Atributos
var empuje:Vector2 = Vector2.ZERO
var dir_rotacion:int = 0
var estado_actual:int = ESTADOS.SPAWN

## Atributos onready
onready var canion:Canion = $Canion
onready var laser:RayoLaser = $LaserBeam2D
onready var estela:Estela = $EstelaPuntoInicio/Trail2D
onready var motor_sfx:Motor = $MotorSFX
onready var colisionador:CollisionShape2D = $CollisionShape2D
onready var impacto_sfx:AudioStreamPlayer = $ImpactosSFX
onready var escudo:Escudo = $Escudo

#JMG
onready var animacion:AnimationPlayer = $AnimationPlayer

## Metodos
func _ready() -> void:
	cambiar_estado(estado_actual)

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	apply_torque_impulse(dir_rotacion * potencia_rotacion)
	apply_central_impulse(empuje.rotated(rotation))

func _process(delta: float) -> void:
	player_input()

func _unhandled_input(event: InputEvent) -> void:
	if not jugador_activo():
		return
	# Control de Escudo
	if event.is_action_pressed("escudo") and not escudo.get_esta_activado():
		escudo.activar()
	
	# Disparo Secundario
	if event.is_action_pressed("disparo_secundario"):
		laser.set_is_casting(true)
	
	if event.is_action_released("disparo_secundario"):
		laser.set_is_casting(false)
	
	# Control de Estela
	if event.is_action_pressed("mover_adelante"):
		estela.set_largo(estela_maxima)
		motor_sfx.sonido_on()
		
	elif event.is_action_pressed("mover_atras"):
		estela.set_largo(0)
		motor_sfx.sonido_on()
	
	if (event.is_action_released("mover_adelante") or event.is_action_released("mover_atras")):
		motor_sfx.sonido_off()

## Metodos Custom
func destruir() -> void:
	cambiar_estado(ESTADOS.MUERTO)
	
func player_input() -> void:
	if not jugador_activo():
		return
	# Empuje
	empuje = Vector2.ZERO
	if Input.is_action_pressed("mover_adelante"):
		#estela.set_largo(estela_maxima)
		empuje = Vector2(potencia_motor,0)
	elif Input.is_action_pressed("mover_atras"):
		#estela.set_largo(0)
		empuje = Vector2(-potencia_motor,0)
		
	# Rotación
	dir_rotacion = 0
	if Input.is_action_pressed("rotar_antihorario"):
		dir_rotacion -=1
	elif Input.is_action_pressed("rotar_horario"):
		dir_rotacion += 1
	
	# Disparo primario
	if Input.is_action_just_pressed("disparo_principal"):
		canion.set_esta_disparando(true)
	
	if Input.is_action_just_released("disparo_principal"):
		canion.set_esta_disparando(false)
	
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
			canion.set_puede_disparar(true)
			Eventos.emit_signal("nave_destruida", global_position, 2)
			queue_free()
		ESTADOS.INVENCIBLE:
			colisionador.set_deferred("disabled", true)
		_:
			printerr("Error cambiando los estados")
	estado_actual = nuevo_estado

func jugador_activo () -> bool:
	if estado_actual in [ESTADOS.MUERTO, ESTADOS.SPAWN]:
		return false
	else:
		return true

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

