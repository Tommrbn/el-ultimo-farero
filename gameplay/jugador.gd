class_name Jugador
extends Node2D

# =====================================================
#  EL FARERO (tu personaje)
#  Probá cambiar estos valores, guardá y volvé a jugar.
# =====================================================
var vida_max := 100.0
var vida := 100.0
var velocidad := 220.0      # píxeles por segundo
var iman_radio := 90.0      # distancia a la que atrae las gemas de experiencia
var regeneracion := 0.0     # vida que recupera por segundo

var direccion_joystick := Vector2.ZERO   # la llena main.gd cuando jugás con touch
var invulnerable := 0.0                  # segundos de invulnerabilidad tras un golpe
var tiempo := 0.0

func _process(delta):
    tiempo += delta
    # Movimiento con teclado (WASD o flechas)
    var dir := Input.get_vector("mover_izq", "mover_der", "mover_arriba", "mover_abajo")
    # Si hay control táctil activo, tiene prioridad
    if direccion_joystick.length() > 0.1:
        dir = direccion_joystick
    if dir.length() > 1.0:
        dir = dir.normalized()
    position += dir * velocidad * delta

    if invulnerable > 0.0:
        invulnerable -= delta
    if regeneracion > 0.0 and vida < vida_max:
        vida = min(vida_max, vida + regeneracion * delta)
    queue_redraw()

func recibir_danio(cantidad: float):
    if invulnerable > 0.0:
        return
    vida -= cantidad
    invulnerable = 0.6

func _draw():
    # Halo de luz del farol (pulsa suavemente)
    var pulso := 1.0 + 0.08 * sin(tiempo * 4.0)
    draw_circle(Vector2.ZERO, 34.0 * pulso, Color(1.0, 0.9, 0.5, 0.10))
    draw_circle(Vector2.ZERO, 24.0 * pulso, Color(1.0, 0.9, 0.5, 0.15))
    # Cuerpo del farero (abrigo azul oscuro)
    var color_cuerpo := Color(0.16, 0.22, 0.35)
    if invulnerable > 0.0 and int(tiempo * 12.0) % 2 == 0:
        color_cuerpo = Color(0.9, 0.3, 0.3)   # parpadeo rojo al recibir daño
    draw_circle(Vector2.ZERO, 12.0, color_cuerpo)
    # Cara
    draw_circle(Vector2(0, -10), 7.0, Color(0.95, 0.85, 0.7))
    # Gorro amarillo de marinero
    draw_rect(Rect2(-8, -20, 16, 5), Color(0.9, 0.85, 0.3))
    # Farol en la mano
    draw_circle(Vector2(13, 0), 5.0, Color(1.0, 0.85, 0.3))
    draw_circle(Vector2(13, 0), 3.0, Color(1.0, 1.0, 0.8))
