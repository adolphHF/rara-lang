.data
newline: .asciiz "\n"
var_doble_x: .word 0
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
    jal func_doble
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
func_doble:
    sw $a0, var_doble_x
    lw $t0, var_doble_x
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    lw $t0, var_doble_x
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    add $t0, $t1, $t0
    move $v0, $t0
    j func_end_doble
    li $v0, 0
func_end_doble:
    jr $ra
