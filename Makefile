all: gussie.js gussie.min.js

%.js:  %.coffee
	coffee -c $^

gussie.min.js:	gussie.js
	closure gussie.js > gussie.min.js
