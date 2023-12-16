PROGRAMS := $(patsubst %, %.exe, $(wildcard *.c *.zig))
CFLAGS = -Wall -Werror -O3

default: $(PROGRAMS)

%.c.exe: %.c
	cc $(FLAGS) $< -o $@

%.zig.exe: %.zig
	zig build-exe -O ReleaseFast $< --name $@

clean:
	-rm -f $(PROGRAMS)
