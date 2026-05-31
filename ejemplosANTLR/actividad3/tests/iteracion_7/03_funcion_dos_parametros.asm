.data
newline: .asciiz "\n"
var_suma_a: .word 0
var_suma_b: .word 0
.text
.globl main
main:
    li $t0, 3
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 4
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal func_suma
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
func_suma:
    sw $a0, var_suma_a
    sw $a1, var_suma_b
    lw $t0, var_suma_a
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_suma_b
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    move $v0, $t0
    j func_end_suma
    li $v0, 0
func_end_suma:
    jr $ra
