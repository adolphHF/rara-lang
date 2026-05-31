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
    li $t0, 2
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_y
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 1
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    sub $t0, $t1, $t0
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    mult $t1, $t0
    mflo $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
