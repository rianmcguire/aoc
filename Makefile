PROGRAMS := $(patsubst %.c, %, $(wildcard *.c))
CFLAGS = -Wall -Werror -O3

default: $(PROGRAMS)

%: %.c
	cc $(FLAGS) $< -o $@

clean:
	-rm $(PROGRAMS)
