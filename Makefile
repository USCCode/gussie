files = gussie.js gussie.min.js

all: $(files)

%.js:  %.coffee
	coffee -c $^

%.min.js:	%.js
	closure $^ > $@

clean:
	rm $(files)
