# Open Access DOI resolver


Welcome to the open access [Digital Object Identifier (DOI)][DOI] resolver: you give it a DOI and it gives you back the URL for an open access version of the article it refers to.

-   [Read more about it](/about)
-   [Get the code on github][code]
-   [See the list of repositories covered](/repositories)

## Try it out

<form action="/resolve" method="get" class="form-inline">
<fieldset>
<input type="text" placeholder="DOI e.g. 10.1000/abcdefg.1" name="doi" />
<button type="submit" class="btn btn-primary">Resolve</button>
</fieldset>
</form>

## How to use it

*This interface is subject to change.*

A HTTP GET request to `/resolve/<DOI here>` should return:

*   A URL for that paper at an institutional repository, in plain text, if that DOI is in the database;
*   404 Not Found error if it's not (including if it's not a valid DOI);
*   400 Bad Request if you don't include a DOI.

A request to `/redirect/<DOI here>` will redirect you straight there instead (just like `dx.doi.org`).

Both will also accept the DOI as a parameter, so `/resolve?doi=<URL-encoded DOI here>` will behave the same as `/resolve/<DOI here>`.


[DOI]: http://en.wikipedia.org/wiki/Digital_object_identifier
[code]: http://github.com/jezcope/doi2oa
