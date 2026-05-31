.data
newline: .asciiz "\n"
var_add: .word 0
.text
.globl main
main:
    li $t0, 5
    sw $t0, var_add
    lw $t0, var_add
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
