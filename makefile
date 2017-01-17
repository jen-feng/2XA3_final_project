all: sufsort

sufsort: sufsort.o asm_io.o driver.c
	gcc -m32 -o sufsort sufsort.o driver.c asm_io.o

sufsort.o: sufsort.asm
	nasm -f elf32 -o sufsort.o sufsort.asm
	
asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm

clean:
	rm *.o sufsort
