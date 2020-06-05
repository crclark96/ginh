prefix = /usr/local

all: ginh

ginh:
	cp ginh.sh ginh
	chmod 755 ginh
	chmod 755 chart

install: ginh
	install -D ginh $(DESTDIR)$(prefix)/bin/ginh
	install -D chart $(DESTDIR)$(prefix)/bin/ginh

clean:
	-rm -f ginh
