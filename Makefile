all: gussie.js

%.js:  %.coffee
	coffee -c $^
