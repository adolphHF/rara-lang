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

_Revisado por Adolfo Hernández Fernández y Aracelli Melissa Boza Zabarburú. Correcciones: Se añadieron los métodos completos implementados en el listener durante esta iteración._
