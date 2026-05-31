.data
newline: .asciiz "\n"
.text
.globl main
main:
    li $t0, 4
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 5
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
    li $t0, 2
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 10
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
    li $v0, 10
    syscall
