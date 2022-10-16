# Meteorito.gd
class_name Meteorito
extends RigidBody2D

## Atributos Export
export var vel_lineal_base:Vector2 = Vector2(100.0, 100.0)
export var vel_ang_base:float = 4.0
export var hitpoints_base:float = 20.0

onready var impacto_sfx:AudioStreamPlayer = $Impactos_sfx
#onready var explota_sfx:AudioStreamPlayer2D = $Explota_stereo
onready var animacion:AnimationPlayer = $AnimationPlayer

## Atributos
var hitpoints:float

## Metodos
#func _ready() -> void:
#	angular_velocity = vel_ang_base

# Contructor
func crear(pos: Vector2, dir: Vector2, tamanio: float) -> void:
	position = pos
	# Calcular masa, tamaño de sprite y de colisionador
	mass *= tamanio
	$Sprite.scale = Vector2.ONE * tamanio
	# radio = diametro / 2
	var radio:int = int ($Sprite.texture.get_size().x / 2.3 * tamanio)
	var forma_colision:CircleShape2D = CircleShape2D.new()
	forma_colision.radius = radio
	$CollisionShape2D.shape = forma_colision
	# Calcular Velocidades
	linear_velocity = (vel_lineal_base * dir / tamanio) * rnd_velocidad()
	angular_velocity = (vel_ang_base / tamanio) * rnd_velocidad()
	# Calcular los hitpoints
	hitpoints = hitpoints_base * tamanio

# Metodos Custom
func rnd_velocidad() -> float:
	randomize()
	return rand_range(1.1, 1.4)

func recibir_danio(danio:float) -> void:
	hitpoints -= danio
	if hitpoints <= 1:
			destruir()
	impacto_sfx.play()
	
func destruir() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	animacion.play("destruir")
	Eventos.emit_signal("destruccion_meteorito", global_position)
	#queue_free()
	
