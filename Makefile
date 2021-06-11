GAMES=	gameSelect.O breakout.O rocks.O
GAMES=	rocks.O

QUESTIONS_DONE=	  parallel_task.srec \
				serial_task.srec \
				kernel_q3.srec \
				kernel_q4.srec \
				kernel_q5.srec \
				kernel_q6.srec \
				kernel_q7.srec \
				kernel_q8.srec \
				kernel_q9.srec

MAKEFLAGS += --no-builtin-rules
AS = wasm
LD = wlink
RM = rm -f
CC = wcc

.PHONY: clean clobber all

all: $(QUESTIONS_DONE)

parallel_task.srec:	parallel_entry.o parallel_task.o
serial_task.srec:	serial_entry.o serial_task.o
kernel_q3.srec:		kernel_q3.o serial_task.o
kernel_q4.srec:		kernel_q4.o serial_task.o
kernel_q5.srec:		kernel_q5.o serial_task.o parallel_task.o
kernel_q6.srec:		kernel_q6.o serial_task.o parallel_task.o $(GAMES)
kernel_q7.srec:		kernel_q7.o serial_task.o parallel_task.o $(GAMES)
kernel_q8.srec:		kernel_q8.o serial_task.o parallel_task.o $(GAMES)
kernel_q9.srec:		kernel_q9.o serial_task.o parallel_task.o $(GAMES)

$(QUESTIONS_DONE):
	$(LD) -o $@ $^

%.o:	%.s
	$(AS) $<

%.o:	%.S
	$(AS) $<

%.s:	%.c
	$(CC) -S $<

clean:
	$(RM) kernel_q*.o serial_entry.[os] serial_task.o parallel_task.o parallel_entry.[os] *~

clobber: clean
	$(RM) *.srec

