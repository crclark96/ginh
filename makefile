prefix = /usr/local

all: ginh

ginh:
	cp ginh.sh ginh
	chmod 755 ginh

install: ginh
	install -D ginh $(DESTDIR)$(prefix)/bin/ginh

clean:
	-rm -f ginh
