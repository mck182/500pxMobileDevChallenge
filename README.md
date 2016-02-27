A simple 500px browser app
==========================

Features:

* Grid of non-cropped non-squared thumbnails with custom layout code
* UI scaled with device DPI
* Infinite scrolling in the thumbnail view
* Details view showing larger size photo with name and author name
* Swipeable details view with infinite swiping
* All photo appearances are animated (faded in)
* Animations during thumbnail->full size and full size->thumbnail view transitions
* Indication of "working" when requesting additional photos (ie when scrolled to the bottom)
* Network errors handling with manual "retry" feature (a button)
* Unit tests coverage using QtTestLib (needs to be compiled separately)

Running the tests
-----------------
The tests require qmake and QtTestLib installed. These should normally come
with any Linux distribution that has Qt installed. On Ubuntu-based distributions
the packages qt5-qmake and qtbase5-dev should suffice.

Once all dependencies are installed, simply cd to the tests/ folder and run:

	qmake .
	make
	make check
