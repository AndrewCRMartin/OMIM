HTML = index.html about.html unavailable.html

INCLUDES = header.tt footer.tt main_menu.tt omim_menu.tt

all: $(HTML)

clean:
	\rm $(HTML)

%.html : %.tt $(INCLUDES)
	tpage --define serversactive='active' $< > $@


