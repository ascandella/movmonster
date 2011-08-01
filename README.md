MovMonster (a movie library organization system)
================================================

MovMonster is a two part ruby/sinatra application for managing a collection of digital movies. Given an input directory where the master media are stored, it will maintain a database using [TMDB](http://www.themoviedb.org/) as its backend.

Features
--------

* Automatic scanning
* Poster caching, including multiple sizes (e.g. thumbnail and full)
* A web interface for browsing and searching your library


Todo
----

* More tests. I wrote a couple basic ones, but the coverage is low right now.
* More configuration options. This evolved out of an app I built for myself, so the options are pretty tailored to my needs at the moment
* A sexy homepage, with screenshots. Cause let's be honest, most of you aren't going to run this, you just want to know what it looks like.


License
-------

Licensed under the WTFPL, so do WTF you'd like with it. That said, I'd appreciate bug reports and/or fork+pull requests.
