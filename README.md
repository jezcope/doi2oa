# Open Access DOI resolver

-   [Go to the DOI resolver][resolver]

This is the code for an open access [Digital Object Identifier (DOI)][DOI] resolver: you give it a DOI and it gives you back the URL for an open access version of the article it refers to.

It can only resolve DOIs for which metadata has been harvested from an open access repository, so odds are good that a given DOI won't resolve.

This is currently a proof-of-concept, based on a very short conversation about things it would be useful to be able to do with DOIs. It's not very full featured. In particular:

1.  There are no scheduled jobs to harvest up-to-data metadata from repositories. It gets updated when and only when I give it a kick.
2.  It only harvests metadata from a defined set of repositories. That set only expands when I manually add a repository.
3.  It doesn't store *any* metadata for each DOI other than an associated URL. There are other ways to [get metadata for a DOI][cn].
3.  It's currently running on a starter-tier PostgreSQL database at [Heroku](http://heroku.com), which means only space for 10,000 rows in the database. They're not big rows, there's just a lot of them — currently a little over 9,800 from a single repository. Heroku has some free MongoDB plans that are based on volume rather than number of rows, so I might switch over to one of those soon.

It's a project I've put together in my spare time too, so I'm using it as an opportunity to learn some bits and bobs. Feel free to [critique, contribute or report feature requests and bugs over at github][code].

[resolver]: http://doi2oa.erambler.co.uk/
[DOI]: http://en.wikipedia.org/wiki/Digital_object_identifier
[code]: http://github.com/jezcope/doi2oa
[cn]: http://crosscite.org/cn/
