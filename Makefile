prefix ?= /usr/local
mandir ?= $(prefix)/share/man
htmldir ?= $(prefix)/share/doc/git-doc
gitdir ?= $(shell git --exec-path)

gitver ?= $(word 3,$(shell git --version))

# this should be set to a 'standard' bsd-type install program
INSTALL ?= install
INSTALL_DATA = $(INSTALL) -c -m 0644
INSTALL_EXE = $(INSTALL) -c -m 0755
INSTALL_DIR = $(INSTALL) -c -d -m 0755

default:
	@echo "git-subtree doesn't need to be built."
	@echo "Just copy it somewhere on your PATH, like /usr/local/bin."
	@echo
	@echo "Try: make doc"
	@echo " or: make test"
	@false

install: install-exe install-doc

install-exe: git-subtree.sh
	$(INSTALL_DIR) $(DESTDIR)/$(gitdir)
	$(INSTALL_EXE) $< $(DESTDIR)/$(gitdir)/git-subtree

install-doc: install-man install-html

install-man: git-subtree.1
	$(INSTALL_DIR) $(DESTDIR)/$(mandir)/man1/
	$(INSTALL_DATA) $< $(DESTDIR)/$(mandir)/man1/

install-html: git-subtree.html
	$(INSTALL_DIR) $(DESTDIR)/$(htmldir)/
	$(INSTALL_DATA) $< $(DESTDIR)/$(htmldir)/

doc: git-subtree.1 git-subtree.html

%.1: %.xml
	xmlto -m manpage-normal.xsl  man $^

%.xml: %.txt asciidoc.conf
	asciidoc -b docbook -d manpage -f asciidoc.conf \
		-agit_version=$(gitver) $<

%.html: %.txt asciidoc.conf
	asciidoc -b xhtml11 -d manpage -f asciidoc.conf \
		-agit_version=$(gitver) $<

test:
	./test.sh

deb:
	./make-package.sh

clean:
	rm -f *~ *.xml *.html *.1
	rm -f git-subtree_*.deb
	rm -f install
	rm -rf subproj mainline
