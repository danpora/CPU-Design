.data 
i: .word 0x4321
j: .word 0x0031
a: .word 0x000B
b: .word 0x002D
c: .word 0x0008
d: .word 0x0036
INT_ADDR: .word 0x00002E
INT_DATA: .word 0x000080
BR_ADDR: .word 0x002C
BR_DATA: .word 0x000D

#Filter Coeffiants 200Hz
#Coef0: .word 0x000096E8
#Coef1: .word 0xFFFE3B4A
#Coef2: .word 0x0003183E
#Coef3: .word 0x00FC5333
#Coef4: .word 0x0003183E
#Coef5: .word 0xFFFE3B4A
#Coef6: .word 0x000096E8

#Coef011: .word 0x00000001
#Coef1_: .word 0xFFFFFFFF
#Coef21: .word 0x00000001
#Coef3_: .word 0xFFFFFFFF
#Coef4_: .word 0x00000001
#Coef5_: .word 0xFFFFFFFF
#Coef6_: .word 0x00000001

#Filter Coeffiants 800Hz
Coef0_1: .word 0xFFFDF88A
Coef1_1: .word 0xFFF2B3A9
Coef2_1: .word 0x0041FFAA
Coef3_1: .word 0x009A828A
Coef4_1: .word 0x0041FFAA
Coef5_1: .word 0xFFF2B3A9
Coef6_1: .word 0xFFFDF88A
.text

	beq $zero, $zero, INIT

DATA_READ:	
	sw $t5, 0x0408 # Require new data from ADXL
	lw $t8, 0x0428 # Take the data from ADXL and put in t8
	sw $t8, 0x0430 # Put the data in t8 to FIFO2 (Filter's FIFO)
	sw $t8, 0x0404
NOP:	j NOP

INIT:
	# loading I2C Configurations		
	lw $t1,4
	lw $t2,8
	lw $t3,12
	lw $t4,16
	lw $t5, 20
	lw $t6, 24
	lw $t7, 28
	lw $a1, 32
	lw $a2, 36
	
	# loading coeffiants
	lw $s0, 40
	lw $s1, 44
	lw $s2, 48
	lw $s3, 52
	lw $s4, 56
	lw $s5, 60
	lw $s6, 64
	
	# storing coeffiants to LPF_CoefX
	sw $s0, 0x040C
	sw $s1, 0x0410
	sw $s2, 0x0414
	sw $s3, 0x0418
	sw $s4, 0x041C
	sw $s5, 0x0420
	sw $s6, 0x0424
	
	# storing I2C configurations to FIFO1
	sw $t1, 0x0408
	sw $t2, 0x0408
	sw $t3, 0x0408
	sw $t4, 0x0408
	sw $t6, 0x0408
	sw $t7, 0x0408
	sw $a1, 0x0408
	sw $a2, 0x0408
	sw $t5, 0x0408		
				
LOOP:	add $t0, $t0, $t0
	add $t0, $t0, $t0
	beq $zero, $zero, LOOP
