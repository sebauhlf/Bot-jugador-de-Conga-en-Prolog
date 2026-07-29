# GinRummyLog
 
Implementación en Prolog (SWI-Prolog) de la lógica de un juego de **Gin Rummy**: validación de combinaciones (*melds*), cálculo de deadwood, armado óptimo de manos, y estrategias de IA (`random`, `greedy`, `pro`) para robar, descartar y decidir cuándo cerrar la ronda. Incluye un servidor de consola jugable y una suite de tests automatizados con `plunit`.
 
Este proyecto fue desarrollado como trabajo práctico del curso de Programación Lógica (FING, UdelaR).
 
## Contenido del repositorio
 
| Archivo | Descripción |
|---|---|
| `lab2_grupo18.pl` | Núcleo de la lógica del juego: reglas de *melds* (sets y escaleras), cálculo de deadwood, búsqueda de la mejor combinación de manos, y las estrategias de IA. |
| `server.pl` | Servidor de consola: reparte cartas, gestiona turnos entre dos jugadores (humano o IA) y corre la partida completa. |
| `test.pl` | Suite de pruebas unitarias (`plunit`) sobre las reglas principales del núcleo lógico. |
 
 
## Requisitos
 
- [SWI-Prolog](https://www.swi-prolog.org/) (probado en versiones recientes de la 9.x).
## Cómo ejecutar
 
### Jugar una partida por consola
 
```bash
swipl server.pl
```
 
Dentro del intérprete:
 
```prolog
?- main.
```
 
El programa va a pedir:
1. Una semilla numérica (para reproducibilidad del mazo).
2. Modo de ejecución: `normal.` (solo se ve la mano propia) o `debug.` (se ven ambas manos y el estado completo).
3. Estrategia de cada jugador: `humano`, `greedy`, `random` o `pro`.
### Correr los tests
 
```bash
swipl test.pl
```
 
Dentro del intérprete:
 
```prolog
?- run_tests.
```
 
## Algunos aspectos destacados
 
- **Motor de reglas declarativo**: validación de *sets* (3-4 cartas del mismo valor, distinto palo) y *runs* (escaleras del mismo palo) usando unificación y backtracking.
- **Optimización de manos**: `best_melds/4` explora combinaciones de *melds* disjuntos y elige la que minimiza el deadwood, usando `setof/3` para ordenar candidatos por costo.
- **IA con distintos niveles de complejidad**: desde decisiones aleatorias hasta una estrategia "pro" que evalúa sinergias entre cartas y descarte visto por el rival para decidir qué carta conservar o tirar
