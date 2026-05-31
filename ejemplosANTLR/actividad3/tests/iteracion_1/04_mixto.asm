.data
newline: .asciiz "\n"
str_0: .asciiz "inicio"
str_1: .asciiz "fin"
.text
.globl main
main:
    li $v0, 4
    la $a0, str_0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 1
    li $a0, 42
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 1
    li $a0, 42
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 4
    la $a0, str_1
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
