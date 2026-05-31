.data
newline: .asciiz "\n"
var_sumaHasta_n: .word 0
var_sumaHasta_acc: .word 0
var_sumaHasta_i: .word 0
.text
.globl main
main:
    li $t0, 5
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal func_sumaHasta
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
func_sumaHasta:
    sw $a0, var_sumaHasta_n
    li $t0, 0
    sw $t0, var_sumaHasta_acc
    li $t0, 1
    sw $t0, var_sumaHasta_i
while_start_1:
    lw $t0, var_sumaHasta_i
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_sumaHasta_n
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    slt $t0, $t1, $t0
    beq $t0, $zero, while_end_1
    lw $t0, var_sumaHasta_acc
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_sumaHasta_i
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    sw $t0, var_sumaHasta_acc
    lw $t0, var_sumaHasta_i
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t0, 1
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    sw $t0, var_sumaHasta_i
    j while_start_1
while_end_1:
    lw $t0, var_sumaHasta_acc
    move $v0, $t0
    j func_end_sumaHasta
    li $v0, 0
func_end_sumaHasta:
    jr $ra
