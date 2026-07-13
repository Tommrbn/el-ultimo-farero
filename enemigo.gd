class_name Enemigo
extends Node2D

# =====================================================
#  CRIATURAS DEL ABISMO
#  Tres tipos: Sombra (común), Medusa (rápida y frágil)
#  y Abisal (lento pero tanque). Persiguen al farero.
# =====================================================
var vida := 10.0
var velocidad := 70.0
var danio := 8.0
var xp := 1
var radio := 12.0
var color := Color(0.22, 0.12, 0.35)
var enfriamiento_ataque := 0.0
var tiempo := randf() * 10.0
var jugador: Node2D = null

# "dureza" crece con el tiempo de partida: los enemigos tienen más vida
static func crear(tipo: int, dureza: float) -> Enemigo:
    var e := Enemigo.new()
    match tipo:
        0:   # Sombra
            e.vida = 10.0 * dureza
            e.velocidad = 70.0
            e.danio = 8.0
            e.xp = 1
            e.radio = 12.0
            e.color = Color(0.22, 0.12, 0.35)
        1:   # Medusa
            e.vida = 6.0 * dureza
            e.velocidad = 125.0
            e.danio = 5.0
            e.xp = 2
            e.radio = 9.0
            e.color = Color(0.15, 0.40, 0.45)
        2:   # Abisal
            e.vida = 45.0 * dureza
            e.velocidad = 42.0
            e.danio = 18.0
            e.xp = 5
            e.radio = 20.0
            e.color = Color(0.38, 0.10, 0.16)
    return e

func _process(delta):
    tiempo += delta
    if enfriamiento_ataque > 0.0:
        enfriamiento_ataque -= delta
    if jugador != null:
        var dir := (jugador.position - position).normalized()
        position += dir * velocidad * delta
    queue_redraw()

func _draw():
    # Cuerpo gelatinoso que ondula
    var ondulacion := 1.0 + 0.12 * sin(tiempo * 5.0)
    draw_circle(Vector2.ZERO, radio * ondulacion, color)
    draw_circle(Vector2.ZERO, radio * ondulacion * 0.72, color.lightened(0.15))
    # Ojos brillantes
    var sep := radio * 0.4
    draw_circle(Vector2(-sep, -2), 2.5, Color(0.6, 1.0, 0.9))
    draw_circle(Vector2(sep, -2), 2.5, Color(0.6, 1.0, 0.9))
