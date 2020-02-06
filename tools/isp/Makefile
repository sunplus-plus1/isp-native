
.PHONY: all
all: isp

isp: isp.o
	gcc -o $@ $^

isp.o: isp.c
	gcc -c -o $@ $^

.PHONY: clean install

clean:
	@rm -rf *.o isp
