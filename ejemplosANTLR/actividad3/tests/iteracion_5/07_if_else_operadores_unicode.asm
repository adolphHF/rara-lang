.data
newline: .asciiz "\n"
var_x: .word 0
var_y: .word 0
.text
.globl main
main:
    li $t0, 10
    sw $t0, var_x
    li $t0, 3
    sw $t0, var_y
    lw $t0, var_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_y
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    div $t1, $t0
    mfhi $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 1
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    seq $t0, $t1, $t0
    beq $t0, $zero, if_else_1
    lw $t0, var_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_y
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    sll $t1, $t1, 1
    add $t0, $t1, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    j if_end_1
if_else_1:
    lw $t0, var_y
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
if_end_1:
    li $v0, 10
    syscall
