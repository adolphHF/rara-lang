.data
newline: .asciiz "\n"
str_0: .asciiz "hola mundo"
str_1: .asciiz "RaraLang"
.text
.globl main
main:
    li $v0, 4
    la $a0, str_0
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
