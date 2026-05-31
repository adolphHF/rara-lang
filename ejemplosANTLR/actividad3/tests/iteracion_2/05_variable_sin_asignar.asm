.data
newline: .asciiz "\n"
var_contador: .word 0
.text
.globl main
main:
    lw $t0, var_contador
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
