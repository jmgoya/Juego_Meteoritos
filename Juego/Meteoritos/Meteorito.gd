# Meteorito.gd
class_name Meteorito
extends RigidBody2D

## Atributos Export
export var vel_lineal_base:Vector2 = Vector2(60.0, 60.0)
export var vel_ang_base:float = 4.0
export var hitpoints_base:float = 20.0

onready var impacto_sfx:AudioStreamPlayer = $Impactos_sfx
#onready var explota_sfx:AudioStreamPlayer2D = $Explota_stereo
onready var animacion:AnimationPlayer = $AnimationPlayer

## Atributos
var hitpoints:float
var esta_en_sector:bool = true setget set_esta_en_sector
var pos_spawn_original:Vector2
var vel_spawn_original:Vector2

# Setter y getter
func set_esta_en_sector(valor: bool) -> void:
	esta_en_sector = valor

# Constructor
func crear(pos: Vector2, dir: Vector2, tamanio: float) -> void:
	position = pos
	pos_spawn_original = position
	# Calcular masa, tamaño de sprite y de colisionador
	mass *= tamanio
	$Sprite.scale = Vector2.ONE * tamanio
	# radio = diametro / 2
	var radio:int = int ($Sprite.texture.get_size().x / 2 * tamanio)
	var forma_colision:CircleShape2D = CircleShape2D.new()
	forma_colision.radius = radio
	$CollisionShape2D.shape = forma_colision
	# Calcular Velocidades
	linear_velocity = (vel_lineal_base * dir / (tamanio)) * rnd_velocidad()
	vel_spawn_original = linear_velocity
	angular_velocity = (vel_ang_base / tamanio) * rnd_velocidad()
	# Calcular los hitpoints
	hitpoints = hitpoints_base * tamanio

## Metodos
func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if esta_en_sector:
		return
	
	var mi_transform := state.get_transform()
	mi_transform.origin = pos_spawn_original
	linear_velocity = vel_spawn_original
	state.set_transform(mi_transform)
	esta_en_sector = true

# Metodos Custom
func rnd_velocidad() -> float:
	randomize()
	return rand_range(1.1, 1.4)

func recibir_danio(danio:float) -> void:
	hitpoints -= danio
	if hitpoints <= 1:
			destruir()
	animacion.play("impacto")
	
func destruir() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	animacion.play("destruir")
	Eventos.emit_signal("destruccion_meteorito", global_position)
	queue_free()
	
