#Player.gd
class_name Player
extends NaveBase

## Atributos Export
export var potencia_motor:int = 30
export var potencia_rotacion:int = 320
export var estela_maxima:int = 150

## Atributos
var empuje:Vector2 = Vector2.ZERO
var dir_rotacion:int = 0

## Atributos onready
onready var laser:RayoLaser = $LaserBeam2D setget ,get_laser
onready var estela:Estela = $EstelaPuntoInicio/Trail2D
onready var motor_sfx:Motor = $MotorSFX
onready var escudo:Escudo = $Escudo setget ,get_escudo

## Setter y Getters
func get_laser() -> RayoLaser:
	return laser

func get_escudo() -> Escudo:
	return escudo

## Metodos 
func _ready() -> void:
	DatosJuego.set_player_actual(self)

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

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	apply_torque_impulse(dir_rotacion * potencia_rotacion)
	apply_central_impulse(empuje.rotated(rotation))

func _process(delta: float) -> void:
	player_input()

## Metodos Custom
func player_input() -> void:
	if not jugador_activo():
		return
	# Empuje
	empuje = Vector2.ZERO
	if Input.is_action_pressed("mover_adelante"):
		#estela.set_largo(estela_maxima)
		empuje = Vector2(potencia_motor,0)
		motor_sfx.sonido_on()
	elif Input.is_action_pressed("mover_atras"):
		#estela.set_largo(0)
		empuje = Vector2(-potencia_motor,0)
		motor_sfx.sonido_off()
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

func jugador_activo () -> bool:
	if estado_actual in [ESTADOS.MUERTO, ESTADOS.SPAWN]:
		return false
	else:
		return true

func desactivar_controles() -> void:
	cambiar_estado(ESTADOS.SPAWN)
	empuje = Vector2.ZERO
	motor_sfx.sonido_off()
	laser.set_is_casting(false)

func reparar_danio() -> void:
	if hitpoints == hitpoints_total :
		return
	hitpoints += 1
