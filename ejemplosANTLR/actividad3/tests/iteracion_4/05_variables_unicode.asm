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
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
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
    lw $t0, var_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_y
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    sra $t0, $t0, 1
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    lw $t0, var_x
    sub $t0, $zero, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
