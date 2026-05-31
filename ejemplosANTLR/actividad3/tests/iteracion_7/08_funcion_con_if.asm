.data
newline: .asciiz "\n"
var_max2_a: .word 0
var_max2_b: .word 0
.text
.globl main
main:
    li $t0, 10
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 3
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal func_max2
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    move $t0, $v0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 2
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 8
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal func_max2
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    move $t0, $v0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
func_max2:
    sw $a0, var_max2_a
    sw $a1, var_max2_b
    lw $t0, var_max2_a
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_max2_b
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t0, $t1
    beq $t0, $zero, if_else_1
    lw $t0, var_max2_a
    move $v0, $t0
    j func_end_max2
    j if_end_1
if_else_1:
    lw $t0, var_max2_b
    move $v0, $t0
    j func_end_max2
if_end_1:
    li $v0, 0
func_end_max2:
    jr $ra
