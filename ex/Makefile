files = nqueens.js nqueens.min.js graph.js graph.min.js

all: $(files)

%.js:  %.coffee
	coffee -c $^

%.min.js:	%.js
	closure $^ > $@

clean:
	rm $(files)
