.data
newline: .asciiz "\n"
.text
.globl main
main:
    li $t0, 10
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 3
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
    li $t0, 20
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 6
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
    li $v0, 10
    syscall
