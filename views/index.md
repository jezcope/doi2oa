# Open Access DOI resolver

[Get the code on github][code]

Welcome to the open access [Digital Object Identifier (DOI)][DOI] resolver: you give it a DOI and it gives you back the URL for an open access version of the article it refers to.

It can only resolve DOIs for which metadata has been harvested from an open access repository, so odds are good that a given DOI won't resolve.

This is currently a proof-of-concept, based on a very short conversation about things it would be useful to be able to do with DOIs. It's not very full featured. In particular:

1.  There are no scheduled jobs to harvest up-to-data metadata from repositories. It gets updated when and only when I give it a kick.
2.  It only harvests metadata from a defined set of repositories. That set only expands when I manually add a repository.
3.  It's currently running on a starter-tier PostgreSQL database at [Heroku](http://heroku.com), which means only space for 10,000 rows in the database.[^1]

It's a project I've put together in my spare time too, so I'm using it as an opportunity to learn some bits and bobs. Feel free to [critique, contribute or report feature requests and bugs over at github][code].

## Try it out

<form action="/resolve" method="get">
<input type="text" name="doi" /> <input type="submit" value="Resolve" />
</form>

## How to use it

*This interface is subject to change.*

A HTTP GET request to `/resolve/<DOI here>` should return:

*   A URL for that paper at an institutional repository, in plain text, if that DOI is in the database;
*   404 Not Found error if it's not (including if it's not a valid DOI);
*   400 Bad Request if you don't include a DOI.

A request to `/redirect/<DOI here>` will redirect you straight there instead (just like `dx.doi.org`).


[DOI]: http://en.wikipedia.org/wiki/Digital_object_identifier
[code]: http://github.com/jezcope/doi2oa

[^1]: They're not big rows, there's just a lot of them — currently a little over 9,800 from a single repository. Heroku has some free MongoDB plans that are based on volume rather than number of rows, so I might switch over to one of those soon.
