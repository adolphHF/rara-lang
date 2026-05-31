.data
newline: .asciiz "\n"
var_x: .word 0
.text
.globl main
main:
    li $t0, 10
    sw $t0, var_x
    lw $t0, var_x
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
