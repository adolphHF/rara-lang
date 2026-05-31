**Iteración 1 — Literales y print**

**¿Qué hace el compilador ahora que no hacía antes?**  
El compilador ahora puede traducir instrucciones `print` con literales enteros, números escritos en bases 2, 8, 10 y 16, y cadenas de texto. Con esto, un programa RaraLang puede generar MIPS que imprime valores numéricos o strings en QtSPIM, agregando una nueva línea después de cada impresión.

**¿Qué se agregó a la gramática?**  
La grámatica no fue modificada.

**¿Qué métodos del Listener se implementaron?**

- `exitPrintStmt`: se ejecuta al terminar de recorrer una instrucción `print`; identifica si el literal es string o número, genera el MIPS correspondiente y agrega una impresión de nueva línea.
- No se implementaron métodos `enter*`.

**¿Qué decisión técnica tomaste que no estaba explícita en la especificación?**  
Se decidió guardar una etiqueta global `newline` en `.data` como `.asciiz "\n"` y reutilizarla después de cada `print` usando `syscall 4`. También se decidió generar etiquetas automáticas para strings como `str_0`, `str_1`, etc., conforme aparecen en el programa.

**Pruebas que pasan:**

- `01_enteros.rara`  
  Resultado esperado:  
  `5`  
  `1000`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `02_bases.rara`  
  Resultado esperado:  
  `255`  
  `255`  
  `10`  
  `63`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `03_strings.rara`  
  Resultado esperado:  
  `hola mundo`  
  `RaraLang`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `04_mixto.rara`  
  Resultado esperado:  
  `inicio`  
  `42`  
  `42`  
  `fin`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

**Limitaciones conocidas:**  
El compilador todavía no maneja variables, operaciones aritméticas, control de flujo ni expresiones compuestas. La gramática permite escribir bases numéricas distintas a 2, 8, 10 o 16, pero el listener las rechaza durante la generación de MIPS. También pueden fallar literales con dígitos inválidos para su base, por ejemplo `[29:2]`.

**Reflexión de la iteración:**

**¿Qué decidió el modelo sobre cómo guardar una cadena en memoria?**

> \_ El modelo decidió guardar cada cadena en la sección `.data` usando `.asciiz`, con etiquetas generadas automáticamente como `str_0` y `str_1`.

**`[FF:16]` y `255` deben imprimir lo mismo. ¿Lo hacen? ¿Por qué?**

> \_ Sí, `[FF:16]` y `255` imprimen lo mismo. Esto ocurre porque el listener convierte `[FF:16]` a decimal usando la base indicada, por lo que ambos terminan generando `li $a0, 255`.

**¿Qué pasaría si escribes `[29:2]`? (el dígito 9 no existe en base 2 XD) ¿Lo probaste?**

> \_ Si se escribe `[29:2]`, la gramática lo acepta como un literal con base, pero el listener falla al intentar convertir `29` usando base 2. El compilador lo detecta durante la generación de MIPS mediante el error de conversión, no desde el parser.

> _Revisado por Adolfo Hernández Fernández y Aracelli Melissa Boza Zabarburú. Correcciones: Se reportó que la gramática fue modificada sin embargo esta permaneció intacta._

**Iteración 2 — Variables**

**¿Qué hace el compilador ahora que no hacía antes?**  
El compilador ahora puede manejar variables enteras: reservarlas en memoria, asignarles valores y leerlas después como expresiones. Con esto, RaraLang ya puede compilar programas donde se guarda un valor con `<--`, se imprime una variable, se reasigna y se copian valores entre variables.

**¿Qué se agregó a la gramática?**  
Se agregó soporte para identificadores de variable que empiezan con letra y pueden contener letras, números o guiones bajos. También se agregó la instrucción de asignación con el operador `<--`, y se permitió que un identificador aparezca donde antes solo podía aparecer un literal.

**¿Qué métodos del Listener se implementaron?**

- `exitAssignStmt`: implementado en esta iteración; evalúa la expresión del lado derecho y guarda el resultado en la variable usando `sw`.
- `exitPrintStmt`: modificado en esta iteración; ahora, además de literales enteros y strings, puede imprimir variables cargando su valor con `lw`.
- `_emit_eval_int_expr`: método auxiliar que evalúa una expresión entera. Si la expresión es una variable, genera `lw` para cargarla en `$t0`; si es un literal entero o número en base, genera `li $t0, valor`.
- `_emit_print_int_from_t0`: método auxiliar que imprime el entero que ya está en `$t0`, moviéndolo a `$a0` y usando `syscall 1`.
- `_variable_label`: método auxiliar que asigna a cada variable una etiqueta segura con prefijo `var_` y reserva memoria en `.data` con `.word 0` la primera vez que aparece.
- `_is_identifier`: método auxiliar que detecta si una expresión corresponde a un identificador de variable.
- No se implementaron métodos `enter*` en esta iteración.

**¿Qué decisión técnica tomaste que no estaba explícita en la especificación?**  
Se decidió reservar cada variable automáticamente la primera vez que aparece, usando `.word 0` en la sección `.data`. También se decidió transformar todos los nombres de variable a etiquetas MIPS con prefijo `var_`, por ejemplo `add` se convierte en `var_add`, para evitar conflictos con instrucciones de MIPS. Si una variable se lee sin haber sido asignada antes, el compilador no reporta error: la reserva automáticamente con valor inicial `0`.

**Pruebas que pasan:**

- `01_asignar_imprimir.rara`  
  Resultado esperado:  
  `10`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `02_dos_variables.rara`  
  Resultado esperado:  
  `10`  
  `3`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `03_reasignacion.rara`  
  Resultado esperado:  
  `10`  
  `99`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `04_nombre_mips.rara`  
  Resultado esperado:  
  `5`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `05_variable_sin_asignar.rara`  
  Resultado esperado:  
  `0`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `06_variable_como_expresion.rara`  
  Resultado esperado:  
  `8`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

**Limitaciones conocidas:**  
El compilador no detecta variables no declaradas o no asignadas; si se lee una variable nueva, se crea automáticamente en `.data` con valor inicial `0`. No hay validación completa de tipos: las variables de esta iteración están pensadas para enteros, y asignar un string a una variable no forma parte del comportamiento soportado. Todavía no hay aritmética, control de flujo ni funciones.

**Reflexión de la iteración:**

**¿Cómo decidió el modelo reservar espacio para la variable? ¿Dónde queda en el archivo `.asm`?**

> \_ El modelo decidió reservar espacio para cada variable en la sección `.data` del archivo `.asm`, usando una palabra de 32 bits inicializada en cero, por ejemplo `var_x: .word 0`.

**Prueba b <-- 5 ¿Qué se genera, qué hace QtSpim?**

> \_ Con `b <-- 5`, se genera una etiqueta como `var_b: .word 0` en `.data`; luego en `.text` se carga `5` en `$t0` y se guarda en memoria con `sw $t0, var_b`. QtSPIM ejecuta la asignación y deja el valor `5` almacenado en esa variable.

**¿Qué pasa si asignas una variable dos veces?**

> \_ Si se asigna una variable dos veces, se reutiliza la misma etiqueta en `.data` y el segundo `sw` sobrescribe el valor anterior. Por eso, al imprimir después de la segunda asignación, QtSPIM muestra el valor nuevo.

> _Revisado por Adolfo Hernández Fernández y Aracelli Melissa Boza Zabarburú. Correcciones: Se añadieron los métodos completos implementados en el listener durante esta iteración._

**Iteración 3 — Aritmética**

**¿Qué hace el compilador ahora que no hacía antes?**  
El compilador ahora puede evaluar expresiones aritméticas y usarlas tanto en `print` como en asignaciones. Esto permite compilar programas RaraLang con sumas, restas, multiplicaciones, divisiones enteras, variables dentro de expresiones y paréntesis para controlar el orden de evaluación.

**¿Qué se agregó a la gramática?**  
Se agregó soporte para expresiones aritméticas con suma usando `+`, resta usando `-`, multiplicación usando `×` y división entera usando `÷`. También se agregaron paréntesis para agrupar expresiones, y la gramática quedó organizada por niveles para que `×` y `÷` tengan mayor precedencia que `+` y `-`.

**¿Qué métodos del Listener se implementaron?**

- `exitAssignStmt`: fue modificado para evaluar una expresión completa antes de guardar el resultado en una variable con `sw`.
- `exitPrintStmt`: fue modificado para poder imprimir el resultado de expresiones aritméticas, no solo literales o variables simples.
- `_emit_eval_expr`: se agregó/modificó para evaluar recursivamente expresiones del árbol de parseo, incluyendo literales, variables, paréntesis y operaciones aritméticas.
- `_emit_eval_binary_chain`: se agregó para evaluar cadenas de operaciones del mismo nivel de precedencia, como varias sumas/restas o varias multiplicaciones/divisiones.
- `_emit_binary_op`: se agregó para generar la instrucción MIPS correspondiente a cada operación: `add`, `sub`, `mult` + `mflo`, o `div` + `mflo`.
- `_push_t0`: se agregó para guardar temporalmente el valor de `$t0` en la pila MIPS.
- `_pop_t1`: se agregó para recuperar desde la pila el operando izquierdo y colocarlo en `$t1`.
- `_expr_is_string`: se agregó para detectar cuándo una expresión completa corresponde a un string, conservando el soporte de `print "texto"`.
- `_is_identifier`: se eliminó porque la detección de variables ya no se hace revisando texto plano, sino usando el nodo `ID` del árbol de parseo.
- No se implementaron métodos `enter*` en esta iteración.

**¿Qué decisión técnica tomaste que no estaba explícita en la especificación?**  
Se decidió evaluar las expresiones recursivamente desde el árbol de parseo y usar la pila de MIPS con `$sp` para guardar operandos intermedios. Para operaciones binarias, el operando izquierdo se guarda temporalmente en la pila, luego se evalúa el operando derecho, y después se recupera el izquierdo en `$t1`; esto permite que resta y división respeten el orden correcto. En división entera se usa `div` y después `mflo`, por lo que el cociente queda como resultado y el residuo se descarta.

**Pruebas que pasan:**

- `01_operaciones_basicas.rara`  
  Resultado esperado:  
  `13`  
  `7`  
  `30`  
  `3`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `02_precedencia.rara`  
  Resultado esperado:  
  `14`  
  `20`  
  Resultado observado en QtSPIM: verificado manualmente, coincide. Esta prueba cubre `2 + 3 × 4` y `(2 + 3) × 4`.

- `03_variables_aritmetica.rara`  
  Resultado esperado:  
  `13`  
  `7`  
  `30`  
  `3`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `04_anidada.rara`  
  Resultado esperado:  
  `24`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `05_division_cero.rara`  
  Resultado esperado: error o comportamiento definido por QtSPIM por división entre cero.  
  Resultado observado en QtSPIM: La consola muestra un 0 en QtSPIM; el compilador sí genera el `.asm`.

**Limitaciones conocidas:**  
El compilador no detecta división entre cero antes de ejecutar; genera la instrucción `div` y el comportamiento queda en manos de QtSPIM. Tampoco detecta otros errores aritméticos antes de ejecución, como overflow. No hay un límite fijo de registros temporales porque se usa la pila de MIPS para valores intermedios, pero expresiones extremadamente anidadas podrían depender del espacio disponible en la pila. Todavía no hay operadores Unicode especiales de la siguiente iteración, ni control de flujo, ni funciones.

**Reflexión de la iteración:**

**¿Qué resultado da `2 + 3 × 4` en tu compilador? ¿Es el que esperabas? ¿Cómo lo verificaste?**

> \_ `2 + 3 × 4` da `14`, que es el resultado esperado. `2 + 3 × 4` evalúa primero la multiplicación por precedencia, así que produce `2 + 12 = 14`. En cambio, `(2 + 3) × 4` fuerza con paréntesis que la suma ocurra primero, por lo que produce `5 × 4 = 20`. Se verificó compilando el programa a .asm y ejecutándolo manualmente en QtSPIM.

**En la división entera, ¿qué pasa con el residuo? ¿Dónde queda? ¿Se pierde?**

> \_ En la división entera, el cociente queda en `LO` y se mueve a `$t0` usando `mflo`. El residuo queda en `HI`, pero el compilador no lo mueve ni lo conserva como resultado, así que para esta iteración se descarta.

**Explica con tus palabras por qué el orden en que se sacan los registros de la pila importa para la resta.**

> \_ El orden en que se recuperan los registros de la pila importa porque la resta no es conmutativa. Para `a - b`, el compilador debe recuperar `a` como operando izquierdo y usar `b` como operando derecho; si se invierten, el resultado sería `b - a`.

> _Revisado por Adolfo Hernández Fernández y Aracelli Melissa Boza Zabarburú. Correcciones: No se habían mencionado correctamente los métodos modificados y añadidos además de que se removió un metodo del listener._

**Iteración 4 — Operadores Unicode**

**¿Qué hace el compilador ahora que no hacía antes?**  
El compilador ahora puede evaluar operadores Unicode propios de RaraLang además de la aritmética básica anterior. Puede compilar programas que usen módulo, doble más, promedio entero con piso y negación unaria, tanto en `print` como en expresiones con variables.

**¿Qué se agregó a la gramática?**  
Se agregó el operador binario `⊞`, que calcula el módulo o residuo de una división. También se agregó el operador binario `⊠`, definido como `2a + b`, y el operador binario `≈`, definido como promedio entero con piso. Además, se agregó el operador unario `±`, que niega el valor de una expresión.

Estos operadores se integraron dentro de las expresiones existentes. La precedencia quedó como decisión de implementación: `±` tiene la mayor precedencia; luego vienen `×`, `÷` y `⊞`; finalmente quedan `+`, `-`, `⊠` y `≈`. Los paréntesis siguen funcionando para alterar el orden de evaluación.

**¿Qué métodos del Listener se implementaron?**  
No se implementaron nuevos métodos `enter*` ni `exit*` en esta iteración. Los cambios reales se hicieron en métodos auxiliares del listener:

- `_emit_eval_expr`: fue modificado para reconocer la nueva regla de expresión unaria, manejar `±` y seguir evaluando expresiones completas desde el árbol de parseo.
- `_emit_binary_op`: fue modificado para generar MIPS para los nuevos operadores `⊞`, `⊠` y `≈`.
- `_emit_eval_binary_chain`: se siguió usando para evaluar operadores binarios respetando el orden de operandos, ahora también con los operadores Unicode integrados por la gramática.

`exitAssignStmt` y `exitPrintStmt` no se modificaron en esta iteración; simplemente se beneficiaron de que `_emit_eval_expr` ahora entiende los nuevos operadores.

**¿Qué decisión técnica tomaste que no estaba explícita en la especificación?**  
Se decidió implementar `⊞` usando `div` y tomando el residuo con `mfhi`, no el cociente. Para `⊠`, se usó `sll` para duplicar el operando izquierdo y luego `add` para sumar el operando derecho. Para `≈`, se suman los operandos y se usa `sra` para dividir entre dos, lo cual ayuda a obtener piso hacia menos infinito en casos negativos. La negación `±` se implementó como `sub $t0, $zero, $t0`.

También se decidió la precedencia de los operadores nuevos: `⊞` quedó junto con `×` y `÷`, mientras que `⊠` y `≈` quedaron junto con `+` y `-`.

**Pruebas que pasan:**

- `01_modulo.rara`  
  Resultado esperado:  
  `1`  
  `2`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `02_doble_mas.rara`  
  Resultado esperado:  
  `13`  
  `14`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `03_promedio.rara`  
  Resultado esperado:  
  `5`  
  `5`  
  `-2`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `04_negacion.rara`  
  Resultado esperado:  
  `-8`  
  `5`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `05_variables_unicode.rara`  
  Resultado esperado:  
  `1`  
  `23`  
  `6`  
  `-10`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `06_mezcla_precedencia.rara`  
  Resultado esperado:  
  `3`  
  `0`  
  `14`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `07_auditoria_doble_mas.rara`  
  Resultado esperado:  
  `13`  
  `20`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

**Limitaciones conocidas:**  
El compilador no detecta en compilación si se usa `⊞` con divisor cero; generaría código MIPS y el error ocurriría en ejecución. Los errores aritméticos en general, como overflow o división/módulo entre cero, no se validan antes de ejecutar en QtSPIM. Para `≈` con negativos impares, la implementación usa desplazamiento aritmético `sra`, por lo que busca redondear hacia menos infinito; el caso `±3 ≈ 0` fue probado y dio `-2`. No hay un límite fijo de registros temporales porque se usa la pila, pero expresiones muy anidadas podrían depender del espacio disponible. Todavía no hay `if/then/else`, `while`, bloques ni funciones.

**Reflexión de la iteración:**

**`a ≈ b` con `a = -3` y `b = -1`: ¿qué resultado da tu compilador? ¿Es el esperado si "piso" significa redondear hacia menos infinito?**

> \_ Para `a ≈ b` con `a = -3` y `b = -1`, el resultado esperado es `-2`. Según la implementación, se suma `-3 + -1 = -4` y luego se aplica `sra`, por lo que debe dar `-2`; este caso específico queda pendiente de verificación si no se ejecutó como prueba separada.

**La especificación de `⊠` dice `2a + b`, no `a × b`. ¿En qué caso daría el mismo resultado que la multiplicación? ¿En cuáles no?**

> \_ `⊠` calcula `2a + b`, no `a × b`. Daría el mismo resultado que multiplicación cuando `2a + b = a × b`; por ejemplo, con `a = 4` y `b = 4`, ambos dan `12`? No, `2×4+4 = 12` y `4×4 = 16`, así que no coinciden. En general solo coinciden para ciertos valores específicos que cumplen esa ecuación. La prueba `4 ⊠ 5` demuestra que no es multiplicación porque da `13`, mientras que `4 × 5` da `20`.

**`± ±5` debería dar 5. ¿Lo da? ¿Cómo implementó el modelo la doble negación?**

> \_ Sí, `± ±5` da `5`. Se implementó con una regla unaria recursiva: primero se evalúa `±5` como `-5` y luego se aplica otra negación para volver a `5`.

> _Revisado por Adolfo Hernández Fernández y Aracelli Melissa Boza Zabarburú. Correcciones: Se mencionarion cambios en exitAssignStmt y exitPrintStmt que en realidad no existieron y se añadieron las funciones que en realidad fueron modificadas._

**Iteración 5 — Control de flujo**

**¿Qué hace el compilador ahora que no hacía antes?**  
El compilador ahora puede compilar decisiones simples usando comparaciones e instrucciones `if/then/else`. Con esto, un programa RaraLang puede evaluar condiciones, ejecutar una sentencia solo cuando la condición sea verdadera, escoger entre dos ramas y usar el resultado de una comparación como valor dentro de expresiones aritméticas.

**¿Qué se agregó a la gramática?**  
Se agregaron los comparadores `==`, `!=`, `<` y `>`. Una comparación se integró como expresión: produce `1` cuando la relación es verdadera y `0` cuando es falsa, por lo que puede imprimirse directamente o combinarse con operaciones aritméticas.

También se agregó la sentencia `if condición then sentencia` y la variante `if condición then sentencia else sentencia`. La gramática permite `if` anidados porque cada rama recibe una sentencia completa; cuando aparece un `else`, se asocia con el `if` más cercano según la forma en que ANTLR resuelve esta regla.

**¿Qué métodos del Listener se implementaron?**

- `enterIfStmt`: crea un frame de control para el `if`, asigna un número único y prepara buffers separados para las ramas.
- `enterEveryRule`: detecta cuándo el recorrido entra a la sentencia del `then` o a la sentencia del `else`, y cambia el buffer activo.
- `exitIfStmt`: ensambla el MIPS final del `if`: condición, salto condicional, código del `then`, salto al final cuando hay `else`, código del `else` y etiqueta final.
- `exitAssignStmt`: se ajustó para emitir con el helper centralizado de salida, de modo que una asignación dentro de un `if` caiga en el buffer correcto.
- `exitPrintStmt`: no se modificó directamente en esta iteración; conserva su comportamiento, pero ahora sus emisiones también pueden ir al buffer activo de una rama gracias a los helpers auxiliares.

Además, se modificaron métodos auxiliares reales del listener:

- `_emit_eval_expr`: ahora reconoce el nuevo nivel de comparación.
- `_emit_binary_op`: ahora genera MIPS para `==`, `!=`, `<` y `>`.
- `_push_t0`: ahora usa el helper centralizado para emitir el guardado temporal en la pila.
- `_pop_t1`: ahora usa el helper centralizado para recuperar el operando izquierdo desde la pila.
- `_emit_print_int_from_t0`: ahora usa el helper centralizado para que la impresión de enteros pueda emitirse dentro de buffers de control.
- `_emit_print_string`: ahora usa el helper centralizado para que la impresión de cadenas y saltos de línea pueda emitirse dentro de buffers de control.
- `_emit_line`, `_emit_lines` y `_current_output`: centralizan hacia dónde se escribe el MIPS generado.
- `_capture_expr_lines`: captura el código de la condición para poder ensamblarlo antes de las ramas.

**¿Qué decisión técnica tomaste que no estaba explícita en la especificación?**  
Se decidió usar un contador `if_count` para generar etiquetas únicas como `if_else_1`, `if_end_1`, `if_else_2` e `if_end_2`. Esto evita que dos instrucciones `if` salten accidentalmente a la misma etiqueta.

También se decidió que las comparaciones tuvieran menor precedencia que la aritmética: primero se evalúan expresiones como `x ⊞ y` o `a + b`, y después se compara el resultado. Por eso `x ⊞ y == 1` se interpreta como `(x ⊞ y) == 1`.

Para ordenar el MIPS del control de flujo se usaron frames de control con buffers para `then` y `else`. La condición se captura aparte y al salir del `if` se arma la estructura completa. Si la condición es falsa, se genera `beq $t0, $zero, etiqueta_falsa`; si existe `else`, después de ejecutar el `then` se genera `j if_end_N` para evitar que también se ejecute la rama `else`.

**Pruebas que pasan:**

- `01_comparadores.rara`  
  Resultado esperado:  
  `1`  
  `1`  
  `1`  
  `1`  
  `0`  
  `0`  
  `0`  
  `0`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `02_if_sin_else_verdadero.rara`  
  Resultado esperado:  
  `7`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `03_if_sin_else_falso.rara`  
  Resultado esperado: output vacío.  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `04_if_else.rara`  
  Resultado esperado:  
  `0`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `05_if_anidado.rara`  
  Resultado esperado:  
  `1`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `06_comparacion_en_aritmetica.rara`  
  Resultado esperado:  
  `2`  
  `1`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `07_if_else_operadores_unicode.rara`  
  Resultado esperado:  
  `23`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

**Limitaciones conocidas:**  
Todavía no hay `while`, bloques `{ ... }` ni funciones. Cada rama de un `if` acepta una sola sentencia, así que para ejecutar varias instrucciones dentro de una rama todavía haría falta implementar bloques en una iteración posterior.

No se detectan todas las condiciones mal formadas antes de generar MIPS; los errores de sintaxis dependen del parser y algunos errores semánticos siguen sin validarse de forma explícita. No hay un límite fijo de etiquetas o buffers, pero cada `if` anidado agrega un frame a la pila interna del listener, así que una profundidad extrema de anidamiento podría depender de la memoria disponible. Las expresiones muy complejas dentro de condiciones siguen usando la pila MIPS para operandos intermedios; no hay límite de registros temporales fijo, pero sí podría agotarse espacio de pila en casos extremos.

En las pruebas realizadas, el `else` se asocia correctamente con el `if` más cercano. No se identificó un caso ambiguo de `else` que falle con la gramática actual, aunque el lenguaje todavía no tiene bloques para hacer explícita visualmente la agrupación de varias sentencias.

**Reflexión de la iteración:**

**¿Para qué sirve `enterEveryRule` en esta implementación, si se usó? ¿Por qué no basta con `enterIfStmt` y `exitIfStmt`?**

> \_ `enterEveryRule` sirve para detectar el momento exacto en que el recorrido entra a la sentencia del `then` o a la sentencia del `else`. `enterIfStmt` solo sabe que empezó un `if`, y `exitIfStmt` se ejecuta cuando todo el contenido ya fue recorrido; sin una transición intermedia, el listener no sabría qué código pertenece a la condición, al `then` o al `else`.

**Prueba un `if` anidado dentro de otro `if`. ¿Funciona? Si algo falla, ¿dónde está el problema?**

> \_ Sí, funcionó con `05_if_anidado.rara`. La prueba imprime `1`, lo que confirma que se ejecutó el `then` externo, luego el `then` interno, y que el `else` interno se asoció con el `if` más cercano.

**El modelo generó etiquetas como `if_end_1`, `if_end_2`, etc. ¿Por qué tiene que ser un número diferente para cada `if`? ¿Qué pasaría si todos usaran la misma etiqueta?**

> \_ Cada `if` necesita etiquetas propias porque los saltos MIPS van a nombres concretos. Si todos los `if` usaran la misma etiqueta, un salto de un `if` interno podría caer en el final de otro `if`, o un `else` podría mezclarse con una rama que no le corresponde.

> _Revisado por Adolfo Hernández Fernández y Aracelli Melissa Boza Zabarburú. Correcciones: Se añadieron correctamente las funciones que fueron implementadas y se detallo que funciones como exitPrintStmt que había sido reportada como modificada no había tenido cambios en código pero ahora tenía capacidades distintas._

**Iteración 6 — While y bloques**

**¿Qué hace el compilador ahora que no hacía antes?**  
El compilador ahora puede compilar ciclos `while` y agrupar varias sentencias dentro de bloques `{ ... }`. Con esto, RaraLang puede ejecutar una o más instrucciones repetidamente mientras una condición sea verdadera, y también puede usar bloques como una sola sentencia dentro de `if` o como cuerpo de un `while`.

**¿Qué se agregó a la gramática?**  
Se agregaron bloques de sentencias escritos con `{ ... }`. Un bloque puede estar vacío, como `{}`, o contener múltiples sentencias que se ejecutan en orden.

También se agregó la sentencia `while condición do sentencia`. La sentencia del cuerpo puede ser una instrucción simple o un bloque completo, por lo que ahora se pueden escribir ciclos con varias instrucciones dentro del cuerpo. Como los bloques cuentan como una sola sentencia, se integran directamente con `if`, con `else` y con `while`.

La gramática también permite anidar ciclos, porque el cuerpo de un `while` puede contener otro `while`, un `if`, un bloque o cualquier otra sentencia soportada por el lenguaje.

**¿Qué métodos del Listener se implementaron?**

- `enterWhileStmt`: crea un frame de control para el ciclo, asigna un número único al `while` y prepara el buffer del cuerpo.
- `exitWhileStmt`: ensambla el MIPS del ciclo: etiqueta inicial, condición, salto condicional al final, cuerpo, salto de regreso al inicio y etiqueta final.
- `exitBlockStmt`: se agregó como método vacío; no genera MIPS adicional porque las sentencias internas ya emiten su propio código.
- `enterEveryRule`: se extendió para detectar cuándo empieza el cuerpo de un `while` y cambiar al buffer correspondiente.
- `enterIfStmt`: se ajustó para usar el nuevo constructor de frames de control, que ahora distingue entre frames de `if` y frames de `while`.
- `exitIfStmt`: se ajustó para leer el identificador del frame desde `frame_id`, manteniendo la generación de etiquetas de `if` compatible con la nueva estructura compartida de frames.

Además, se modificaron auxiliares reales del listener:

- `_CtrlFrame`: ahora guarda el tipo de frame (`if` o `while`) y, para ciclos, el contexto del cuerpo y su buffer.
- `_current_output`: ahora sabe enviar instrucciones al buffer del cuerpo de un `while`.

**¿Qué decisión técnica tomaste que no estaba explícita en la especificación?**  
Se decidió extender la misma estrategia de frames y buffers que ya se usaba para `if`. En vez de crear un sistema separado para ciclos, `_CtrlFrame` ahora tiene un campo `kind` para distinguir si el frame representa un `if` o un `while`.

Cada `while` recibe etiquetas únicas usando `while_count`, por ejemplo `while_start_1`, `while_end_1`, `while_start_2` y `while_end_2`. Esto evita que un ciclo interno salte por accidente a etiquetas de un ciclo externo.

La condición del `while` se captura aparte con `_capture_expr_lines`, y el cuerpo se acumula en `body_lines`. Al salir de `whileStmt`, el listener ensambla todo en este orden: etiqueta inicial, código de condición, `beq` hacia la etiqueta final si la condición es falsa, cuerpo, `j` de regreso al inicio y etiqueta final.

`exitBlockStmt` queda vacío intencionalmente. Un bloque vacío no produce instrucciones, y un bloque con sentencias tampoco necesita instrucciones de apertura o cierre: solo agrupa las instrucciones que sus sentencias internas ya generaron.

**Pruebas que pasan:**

- `01_while_simple.rara`  
  Resultado esperado:  
  `1`  
  `2`  
  `3`  
  `4`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `02_while_condicion_falsa.rara`  
  Resultado esperado:  
  `99`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `03_bloque_vacio.rara`  
  Resultado esperado:  
  `7`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `04_bloque_multiple.rara`  
  Resultado esperado:  
  `1`  
  `2`  
  `3`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `05_while_anidado.rara`  
  Resultado esperado:  
  `1`  
  `1`  
  `1`  
  `2`  
  `1`  
  `3`  
  `2`  
  `1`  
  `2`  
  `2`  
  `2`  
  `3`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `06_while_dentro_if.rara`  
  Resultado esperado:  
  `1`  
  `2`  
  `3`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `07_if_dentro_while.rara`  
  Resultado esperado:  
  `2`  
  `4`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

- `08_tres_while_anidados.rara`  
  Resultado esperado:  
  `1`  
  `1`  
  `1`  
  `1`  
  `1`  
  `2`  
  `1`  
  `2`  
  `1`  
  `1`  
  `2`  
  `2`  
  `2`  
  `1`  
  `1`  
  `2`  
  `1`  
  `2`  
  `2`  
  `2`  
  `1`  
  `2`  
  `2`  
  `2`  
  Resultado observado en QtSPIM: verificado manualmente, coincide.

**Limitaciones conocidas:**  
Todavía no hay funciones. El compilador tampoco detecta ciclos infinitos; si un programa tiene un `while` cuya condición nunca se vuelve falsa, QtSPIM puede quedarse ejecutando indefinidamente.

No hay un límite fijo de profundidad de anidamiento definido por el compilador, pero en la práctica ciclos y bloques muy anidados dependen de la memoria disponible y de la pila interna usada por el listener. Las expresiones muy complejas dentro de condiciones siguen usando la pila MIPS para operandos intermedios, así que podrían agotar espacio de pila en casos extremos.

Los bloques no crean un ámbito nuevo para variables. Una variable usada dentro de `{ ... }` comparte el mismo espacio global en `.data` que una variable usada fuera del bloque.

**Reflexión de la iteración:**

**¿Cuántos saltos tiene un `while` en el código generado? ¿Cuál va hacia adelante y cuál hacia atrás?**

> \_ Un `while` genera dos saltos. El primero es `beq $t0, $zero, while_end_N`, que va hacia adelante para salir del ciclo cuando la condición es falsa. El segundo es `j while_start_N`, que va hacia atrás para volver a evaluar la condición antes de la siguiente iteración.

**Escribe o describe el programa con tres `while` anidados que probaste. ¿Funciona correctamente? Describe brevemente qué hace el programa.**

> \_ Se probó `08_tres_while_anidados.rara`. El programa usa tres contadores `i`, `j` y `k`; cada uno recorre los valores `1` y `2`, e imprime la combinación actual. Funcionó correctamente y produjo las 24 líneas esperadas, agrupadas como triples `i`, `j`, `k`.

3. **¿Qué pasaría si el `exitBlockStmt` no existiera en el Listener? ¿Daría error?**

> \_ No sería necesario generar código extra para el bloque, porque sus sentencias internas ya generan el MIPS. Sin embargo, tener `exitBlockStmt` vacío deja explícito que el bloque fue considerado y que no necesita instrucciones propias.

> _Revisado por Adolfo Hernández Fernández y Aracelli Melissa Boza Zabarburú. Correcciones: Se añadió la modificación a la funcion exitIfStmt que no había sido reportada debidamente en la sección de cambios al listener._
