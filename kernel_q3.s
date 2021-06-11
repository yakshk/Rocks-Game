.global main
.text

main:
	sw $0, 0x72003($0)		#Acknowledge outstanding interupts.
	addi $2, $0, 24			#Set timer count value to 1 sec.
	sw $2, 0x72001($0)		#Store that value in to the counter.

	movsg $2, $cctrl		#copy the current value of $cctrl into $2.
	andi $2, $2, 0x000F		#Disable all interupts.
	ori $2, $2, 0x42		#Enable required interupts.
	movgs $cctrl, $2		#Copy the new CPU control value back in to $cctrl.
	
	movsg $2, $evec			#Copy the old handler's address to $2.
	sw $2, oldVector($0)		#Save it to memory.
	la $2, handler			#Get the address of the handler.
	movgs $evec, $2			#Copy it in to the $evec register.
	
	addi $2, $0, 0x3		#Prime $2 for timer enable and auto-restart.
	sw $2, 0x72000($0)		#Store $2 into the Timer Control Register.
	
	jal serial_main
	
handler:
	movsg $13, $estat		#Store $estat in $13.
	andi $13, $13, 0xFFB0		#And with the wanted interupt.
	beqz $13, handleTimer
	
	lw $13, oldVector($0)		#Default exception handler.
	jr $13
	
handleTimer:
	lw $13, counter($0)		#Load 'counter' into $13.
	addi $13, $13, 1		#Increment $13 by 1.
	sw $13, counter($0)		#Save $13 back into 'counter'.
	
	sw $0, 0x72003($0)		#Acknowledge interrupt.
	
	rfe

.bss
oldVector:
	.word	
