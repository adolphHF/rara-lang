**Iteración 1 — Literales y print**

**¿Qué hace el compilador ahora que no hacía antes?**  
El compilador ahora puede traducir instrucciones `print` con literales enteros, números escritos en bases 2, 8, 10 y 16, y cadenas de texto. Con esto, un programa RaraLang puede generar MIPS que imprime valores numéricos o strings en QtSPIM, agregando una nueva línea después de cada impresión.

**¿Qué se agregó a la gramática?**  
El lenguaje acepta una instrucción `print` seguida de una expresión literal. Las expresiones permitidas son enteros decimales, números con formato `[dígitos:base]` y strings entre comillas dobles.

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

> _Revisado por Adolfo Hernández Fernández y Aracelli Melissa Boza Zabarburú. Correcciones: ninguna._
