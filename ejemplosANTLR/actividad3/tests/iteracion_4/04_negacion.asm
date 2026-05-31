.data
newline: .asciiz "\n"
.text
.globl main
main:
    li $t0, 8
    sub $t0, $zero, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $t0, 5
    sub $t0, $zero, $t0
    sub $t0, $zero, $t0
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
