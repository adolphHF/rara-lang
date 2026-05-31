.data
newline: .asciiz "\n"
var_i: .word 0
var_j: .word 0
.text
.globl main
main:
    li $t0, 1
    sw $t0, var_i
while_start_1:
    lw $t0, var_i
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 3
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t1, $t0
    beq $t0, $zero, while_end_1
    li $t0, 1
    sw $t0, var_j
while_start_2:
    lw $t0, var_j
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t1, $t0
    beq $t0, $zero, while_end_2
    lw $t0, var_i
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    lw $t0, var_j
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    lw $t0, var_j
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 1
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    sw $t0, var_j
    j while_start_2
while_end_2:
    lw $t0, var_i
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 1
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    sw $t0, var_i
    j while_start_1
while_end_1:
    li $v0, 10
    syscall
