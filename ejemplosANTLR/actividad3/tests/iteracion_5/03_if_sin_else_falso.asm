.data
newline: .asciiz "\n"
var_x: .word 0
.text
.globl main
main:
    li $t0, 3
    sw $t0, var_x
    lw $t0, var_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 5
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t0, $t1
    beq $t0, $zero, if_end_1
    lw $t0, var_x
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
if_end_1:
    li $v0, 10
    syscall
