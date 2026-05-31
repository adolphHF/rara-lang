.data
newline: .asciiz "\n"
.text
.globl main
main:
    li $t0, 5
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 5
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    seq $t0, $t1, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 5
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 3
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    sne $t0, $t1, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 2
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 7
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t1, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 9
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t0, $t1
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 5
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    seq $t0, $t1, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 5
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 5
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    sne $t0, $t1, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 7
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 2
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t1, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 4
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 9
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t0, $t1
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
