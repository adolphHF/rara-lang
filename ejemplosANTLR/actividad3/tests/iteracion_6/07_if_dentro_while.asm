.data
newline: .asciiz "\n"
var_x: .word 0
.text
.globl main
main:
    li $t0, 1
    sw $t0, var_x
while_start_1:
    lw $t0, var_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 6
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t1, $t0
    beq $t0, $zero, while_end_1
    lw $t0, var_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 2
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    div $t1, $t0
    mfhi $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 0
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    seq $t0, $t1, $t0
    beq $t0, $zero, if_end_1
    lw $t0, var_x
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
if_end_1:
    lw $t0, var_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 1
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    sw $t0, var_x
    j while_start_1
while_end_1:
    li $v0, 10
    syscall
