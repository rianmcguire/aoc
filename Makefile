PROGRAMS := $(patsubst %, %.exe, $(wildcard *.c *.zig *.go *.rs))
CFLAGS = -Wall -Werror -O3

default: $(PROGRAMS)

%.c.exe: %.c
	cc $(FLAGS) $< -o $@

%.zig.exe: %.zig
	zig build-exe -O ReleaseFast $< --name $@

%.go.exe: %.go
	go build -o $@ $<

%.rs.exe: %.rs
	rustc -o $@ $<

clean:
	-rm -f $(PROGRAMS)