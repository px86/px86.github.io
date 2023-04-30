SOURCEDIR = ./source
BUILDDIR = ./build
PYTHON = python3

all: clean site server

site:
	emacs -Q --script ./build-site.el

assets:
	cp -r $(SOURCEDIR)/assets $(BUILDDIR)

server:
	$(PYTHON) -m http.server --directory $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR)
