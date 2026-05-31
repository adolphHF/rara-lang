.data
newline: .asciiz "\n"
.text
.globl main
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal func_cinco
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
func_cinco:
    li $t0, 5
    move $v0, $t0
    j func_end_cinco
    li $v0, 0
func_end_cinco:
    jr $ra
