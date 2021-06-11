.global main
.text

.equ pcbLink, 0
.equ pcbReg1, 1
.equ pcbReg2, 2
.equ pcbReg3, 3
.equ pcbReg4, 4
.equ pcbReg5, 5
.equ pcbReg6, 6
.equ pcbReg7, 7
.equ pcbReg8, 8
.equ pcbReg9, 9
.equ pcbReg10, 10
.equ pcbReg11, 11
.equ pcbReg12, 12
.equ pcbReg13, 13
.equ pcbSP, 14
.equ pcbRA, 15
.equ pcbEAR, 16
.equ pcbCCTRL, 17
.equ pcbTimeSlice, 18

main:
	#Serial PCB:
	#Setup the PCB for the serial task.
	la $1, serialPCB		#Store 'serialPCB' into $1.
	
	#Setup the PCB link field.
	la $2, parallelPCB		#Store 'parallelPCB' into $2.
	sw $2, pcbLink($1)		#Store $2 into 'pcbLink'.
	
	#Setup the PCB stack pointer.
	la $2, serialStack		#Store 'serialStack' into $2.
	sw $2, pcbSP($1)		#Store $2 into 'pcbSP'.
	
	#Setup the PCB $ear field.
	la $2, serial_main		#Store 'serial_main' into $2.
	sw $2, pcbEAR($1)		#Store $2 into 'pcbEAR'.
	
	#Setup time slice.
	addui $2, $0, 1			#Set $2 to 1.
	sw $2, pcbTimeSlice($1)		#Store $2 in 'pcbTimeSlice'.
	
	#Setup RA
	la $2, fixExit			#Store 'fixExit' in $2.
	sw $2, pcbRA($1)		#Store $2 in 'pcbRA'.
	
	#Parallel PCB:
	#Setup the PCB for the serial task.
	la $1, parallelPCB		#Store 'parallelPCB' into $1.
	
	#Setip the PCB link field.
	la $2, rocksPCB			#Store 'rocksPCB' into $2.
	sw $2, pcbLink($1)		#Store $2 into 'pcbLink'.
	
	#Setup the PCB stack pointer.
	la $2, parallelStack		#Store 'parallelStack' into $2.
	sw $2, pcbSP($1)		#Store $2 into 'pcbSP'.
	
	#Setup the PCB $ear field.
	la $2, parallel_main		#Store 'parallel_main' into $2.
	sw $2, pcbEAR($1)		#Store $2 into 'pcbEAR'.
	
	#Setup time slice.
	addui $2, $0, 1			#Set $2 to 1.
	sw $2, pcbTimeSlice($1)		#Store $2 in 'pcbTimeSlice'.
	
	#Setup RA
	la $2, fixExit			#Store 'fixExit' in $2.
	sw $2, pcbRA($1)		#Store $2 in 'pcbRA'.
	
	#Rocks PCB:
	#Setup the PCB for the rocks task.
	la $1, rocksPCB		#Store 'rocksPCB' into $1.
	
	#Setup the PCB link field.
	la $2, serialPCB		#Store 'serialPCB' into $2.
	sw $2, pcbLink($1)		#Store $2 into 'pcbLink'.
	
	#Setup the PCB stack pointer.
	la $2, rocksStack		#Store 'parallelStack' into $2.
	sw $2, pcbSP($1)		#Store $2 into 'rocksStack'.
	
	#Setup the PCB $ear field.
	la $2, rocks_main		#Store 'parallel_main' into $2.
	sw $2, pcbEAR($1)		#Store $2 into 'pcbEAR'.
	
	#Setup time slice.
	addui $2, $0, 4			#Set $2 to 4.
	sw $2, pcbTimeSlice($1)		#Store $2 in 'pcbTimeSlice'.
	
	#Setup RA
	la $2, fixExit			#Store 'fixExit' in $2.
	sw $2, pcbRA($1)		#Store $2 in 'pcbRA'.
	
	#Initialise 'currentTask'.
	la $1, serialPCB		#Store 'serialPCB' in $2.
	sw $1, currentTask($0)		#Store $2 in 'currentTask'.

	sw $0, 0x72003($0)		#Acknowledge outstanding interupts.
	addi $2, $0, 24			#Set timer count value to 1 sec.
	sw $2, 0x72001($0)		#Store that value in to the counter.
	
	addi $2, $0, 0x4D		#Setup timer interupts: OIE, KU, OKU and IRQ2.
	movgs $cctrl, $2		#Copy the new CPU control value back in to $cctrl.
	
	movsg $2, $evec			#Copy the old handler's address to $2.
	sw $2, oldVector($0)		#Save it to memory.
	la $2, handler			#Get the address of the handler.
	movgs $evec, $2			#Copy it in to the $evec register.
	
	addi $2, $0, 0x3		#Prime $2 for timer enable and auto-restart.
	sw $2, 0x72000($0)		#Store $2 into the Timer Control Register.
	
	j loadContext
	
handler:
	movsg $13, $estat		#Store $estat in $13.
	andi $13, $13, 0xFFB0		#And with the wanted interupt.
	beqz $13, handleTimer
	
	lw $13, oldVector($0)		#Default exception handler.
	jr $13
	
handleTimer:
	sw $0, 0x72003($0)		#Acknowledge interrupt.

	lw $13, counter($0)		#Load 'counter' into $13.
	addi $13, $13, 1		#Increment $13 by 1.
	sw $13, counter($0)		#Save $13 back into 'counter'.
	
	#Calculate new time slice.
	lw $13, timeSlice($0)		#Get current time slice.
	subui $13, $13, 1		#Subtract one.
	
	sw $13, timeSlice($0)		#Save $13 into 'timeSlice'.
	beqz $13, dispatcher		#Go to dispatcher if $13 equals 0.
	
	rfe
	
dispatcher:

saveContext:
	lw $13, currentTask($0)		#Store 'currentTask' into $13.
	
	sw $1, pcbReg1($13)		#Save register $1.
	sw $2, pcbReg2($13)		#Save register $2.
	sw $3, pcbReg3($13)		#Save register $3.
	sw $4, pcbReg4($13)		#Save register $4.
	sw $5, pcbReg5($13)		#Save register $5.
	sw $6, pcbReg6($13)		#Save register $6.
	sw $7, pcbReg7($13)		#Save register $7.
	sw $8, pcbReg8($13)		#Save register $8.
	sw $9, pcbReg9($13)		#Save register $9.
	sw $10, pcbReg10($13)		#Save register $10.
	sw $11, pcbReg11($13)		#Save register $11.
	sw $12, pcbReg12($13)		#Save register $12.
	sw $sp, pcbSP($13)		#Save register $sp.
	sw $ra, pcbRA($13)		#Save register $ra.
	
	movsg $1, $ers			#Copy $ers into $1.
	sw $1, pcbReg13($13)		#Save $1 into 'pcbReg13'.
	
	movsg $1, $ear			#Copy $ear into $1.
	sw $1, pcbEAR($13)		#Save $1 into 'pcbEAR'.
	
	movsg $1, $cctrl		#Copy $cctrl into $1.
	sw $1, pcbCCTRL($13)		#Save $1 into 'pcbCCTRL'.

schedule:
	#Get current task.
	lw $13, currentTask($0)		#Save 'currentTask' into $13.
	
	#Remember current task.
	sw $13, previousTask($0)	#Save $13 into 'previousTask'.
	
	#Get next task.
	lw $13, pcbLink($13)		#Save 'pcbLink' into $13.
	
	#Set the next task to perform.
	sw $13, currentTask($0)		#Save $13 into 'currentTask'.

loadContext:
	#Get current task.
	lw $13, currentTask($0)		#Save 'currentTask' into $13.
	
	#Load $ers.
	lw $2, pcbReg13($13)		#Save 'pcbReg13' into $2.
	movgs $ers, $2			#Save $2 into $ers.
	
	#Load $ear.
	lw $2, pcbEAR($13)		#Save 'pcbEAR' into $2.
	movgs $ear, $2			#Save $2 into $ers.
	
	#Load $cctrl.
	lw $2, pcbCCTRL($13)		#Save 'pcbCCTRL' into $2.
	movgs $cctrl, $2		#Save $2 into $ers.
	
	#Load the time slice.
	lw $2, pcbTimeSlice($13)	#Save 'pcbTimeSlice' into $2.
	sw $2, timeSlice($0)		#Save $2 into 'timeSlice'.
	
	#Load registers.
	lw $1, pcbReg1($13)		#Save register $1.
	lw $2, pcbReg2($13)		#Save register $2.
	lw $3, pcbReg3($13)		#Save register $3.
	lw $4, pcbReg4($13)		#Save register $4.
	lw $5, pcbReg5($13)		#Save register $5.
	lw $6, pcbReg6($13)		#Save register $6.
	lw $7, pcbReg7($13)		#Save register $7.
	lw $8, pcbReg8($13)		#Save register $8.
	lw $9, pcbReg9($13)		#Save register $9.
	lw $10, pcbReg10($13)		#Save register $10.
	lw $11, pcbReg11($13)		#Save register $11.
	lw $12, pcbReg12($13)		#Save register $12.
	lw $sp, pcbSP($13)		#Save register $sp.
	lw $ra, pcbRA($13)		#Save register $ra.
	
	rfe
	
fixExit:
	lw $2, previousTask($0)		#Store 'previousTask' in $2.
	lw $3, currentTask($0)		#Store 'currentTask' in $3.
	
	seq $6, $2, $3
	bnez $6, idleTask
	
	lw $4, pcbLink($3)		#Store 'pcbLink' in $4.
	lw $5, pcbTimeSlice($3)		#Store 'pcbTimeSlice' in $5.
	
	sw $4, pcbLink($2)		#Store $4 in 'pcbLink'.
	sw $4, currentTask($0)		#Store $4 in 'currentTask'.
	sw $5, timeSlice($0)		#Store $5 in 'timeSlice'.
	
	j loadContext
	
idleTask:
	#Display "byE_"
	sw $0, 0x73004($0)		#Acknowledge interrupt.

	addi $2, $0, 0x7C		#Store the letter 'b'.
	sw $2, 0x73006($0)		#Print 'b' in the left-most SSD.
	
	addi $2, $0, 0x6E		#Store the letter 'y'.
	sw $2, 0x73007($0)		#Print 'd' in the second (from left) SSD.
	
	addi $2, $0, 0x79		#Store the letter 'E'.
	sw $2, 0x73008($0)		#Print 'E' in the third (from left) SSD.
	
	addi $2, $0, 0x8		#Store the letter '_'.
	sw $2, 0x73009($0)		#Print '_' in the right-most SSD.
	
	j idleTask
	

.bss
	currentTask:
		.word
	previousTask:
		.word
	timeSlice:
		.word
	oldVector:
		.word
	serialPCB:
		.space	19
	parallelPCB:
		.space	19
	rocksPCB:
		.space	19
		.space  200
	serialStack:
		.space	200
	parallelStack:
		.space 200
	rocksStack:
