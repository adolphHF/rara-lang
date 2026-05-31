.data
newline: .asciiz "\n"
.text
.globl main
main:
    li $t0, 7
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 3
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
    li $t0, 8
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 3
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
    li $t0, 3
    sub $t0, $zero, $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 0
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
    li $v0, 10
    syscall
