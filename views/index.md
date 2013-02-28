# Open Access DOI resolver

Welcome to the open access [Digital Object Identifier (DOI)][DOI] resolver: you give it a DOI and it gives you back the URL for an open access version of the article it refers to.

It can only resolve DOIs for which metadata has been harvested from an open access repository, so odds are good that a given DOI won't resolve.

This is currently a proof-of-concept, based on a very short conversation about things it would be useful to be able to do with DOIs. It's not very full featured. In particular:

1.  There are no scheduled jobs to harvest up-to-data metadata from repositories. It gets updated when and only when I give it a kick.
2.  It only harvests metadata from a defined set of repositories. That set only expands when I manually add a repository.

<form action="/resolve" method="get">
<input type="text" name="doi" /> <input type="submit" value="Resolve" />
</form>

[Get the code on github][code]


[DOI]: http://en.wikipedia.org/wiki/Digital_object_identifier
[code]: http://github.com/jezcope/doi-oa
