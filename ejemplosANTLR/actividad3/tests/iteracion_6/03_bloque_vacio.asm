.data
newline: .asciiz "\n"
var_x: .word 0
.text
.globl main
main:
    li $t0, 1
    sw $t0, var_x
    lw $t0, var_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 1
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    seq $t0, $t1, $t0
    beq $t0, $zero, if_end_1
if_end_1:
    li $t0, 7
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
