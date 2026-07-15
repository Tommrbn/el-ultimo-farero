# Distingue el director de un actor del juego

El estudiante explicó correctamente que `main.gd` dirige el funcionamiento general de la partida, mientras que `jugador.gd` contiene el comportamiento propio del personaje controlado. Esta separación de responsabilidades ya puede usarse como base para localizar código y diagnosticar sistemas.

**Evidence:** al comparar ambos archivos, identificó espontáneamente a `main.gd` como director y a `jugador.gd` como programación específica del personaje.

**Implications:** puede avanzar desde el mapa de archivos hacia el ciclo de vida del director, pero todavía debe afianzar la cadena completa de arranque y distinguir creación de comportamiento.
