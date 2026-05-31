.data
newline: .asciiz "\n"
var_cuenta_n: .word 0
.text
.globl main
main:
    li $t0, 3
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal func_cuenta
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
func_cuenta:
    sw $a0, var_cuenta_n
    lw $t0, var_cuenta_n
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 0
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    seq $t0, $t1, $t0
    beq $t0, $zero, if_else_1
    li $t0, 0
    move $v0, $t0
    j func_end_cuenta
    j if_end_1
if_else_1:
    lw $t0, var_cuenta_n
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 1
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    sub $t0, $t1, $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal func_cuenta
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    move $t0, $v0
    move $v0, $t0
    j func_end_cuenta
if_end_1:
    li $v0, 0
func_end_cuenta:
    jr $ra
