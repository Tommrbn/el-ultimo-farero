# El Último Farero 🏮

Prototipo roguelite estilo *survivors* hecho en **Godot 4**.

Sos el último farero de una costa maldita. Cada noche, las criaturas del
abismo salen del mar. Tu farol dispara orbes de luz automáticamente hacia
el enemigo más cercano: vos solo tenés que moverte, esquivar y sobrevivir.
Al juntar experiencia subís de nivel y elegís mejoras.

## Cómo jugarlo (5 minutos)

1. Descargá **Godot 4.3 o superior** desde https://godotengine.org/download
   (la versión normal, NO la que dice ".NET"). No requiere instalación: es un solo ejecutable.
2. Abrí Godot → botón **Importar** → buscá la carpeta `el-ultimo-farero` y
   seleccioná el archivo `project.godot` → **Importar y editar**.
3. Con el proyecto abierto, apretá **F5** (o el botón ▶ arriba a la derecha).

## Controles

- **PC:** WASD o flechas para moverte. El farol dispara solo.
- **Celular/táctil:** apoyá el dedo y arrastrá en la dirección que quieras ir.
- Al subir de nivel el juego se pausa: hacé clic en una de las 3 mejoras.

## Cómo modificar el juego (sin saber programar)

Todos los archivos `.gd` son texto con comentarios en español. Los valores
importantes están al principio de cada archivo:

- `main.gd` → daño, velocidad de disparo, dificultad, lista de mejoras
- `jugador.gd` → vida, velocidad de movimiento, radio del imán
- `enemigo.gd` → vida, velocidad y daño de cada tipo de criatura

Cambiá un número, guardá con **Ctrl+S** y volvé a apretar **F5**. Así se aprende.

## Subirlo a GitHub (backup + seguir desde otra PC)

1. Creá una cuenta en https://github.com y un repositorio nuevo (privado está bien).
2. Instalá **GitHub Desktop** (https://desktop.github.com), es todo con clicks.
3. En GitHub Desktop: *Add local repository* → elegí esta carpeta → *Publish repository*.
4. Cada vez que avances: escribí un mensajito de qué cambiaste → **Commit** → **Push**.
5. En otra PC: GitHub Desktop → *Clone repository* → listo, seguís donde quedaste.

La carpeta `.godot/` ya está excluida con el `.gitignore` incluido.

## Próximos pasos sugeridos (en orden)

1. Jugalo y ajustá números hasta que se sienta bien (esto es el 80% del diseño).
2. Agregar sonidos (gratis en https://freesound.org o generados en https://sfxr.me).
3. Un arma nueva (ej: el haz giratorio del faro que barre la pantalla).
4. Sprites dibujados reemplazando los `_draw()` (assets gratis en https://itch.io o https://kenney.nl).
5. Un jefe cada 3 minutos.
6. Exportar a Android/PC desde Godot: Proyecto → Exportar.
