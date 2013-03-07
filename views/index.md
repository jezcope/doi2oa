# Open Access DOI resolver


Welcome to the open access [Digital Object Identifier (DOI)][DOI] resolver: you give it a DOI and it gives you back the URL for an open access version of the article it refers to.

-   [Read more about it](/about)
-   [Get the code on github][code]
-   [See the list of repositories covered](/repositories)
-   [Have an opinion? Comment on the blog post](http://erambler.co.uk/blog/from-doi-to-open-access/index.html)

## Try it out

<form action="/redirect" method="get" class="form-inline">
<fieldset>
<input type="text" placeholder="DOI e.g. 10.1111/j.1476-5381.2012.02129.x" name="doi" />
<button type="submit" class="btn btn-primary">Find it</button>
</fieldset>
</form>

This will only work for DOIs that have been harvested. For example, try `10.1007/s00148-012-0424-x`.

## How to use it

*This interface is subject to change.*

A HTTP GET request to `/resolve/<DOI here>` should return:

*   A URL for that paper at an institutional repository, in plain text, if that DOI is in the database;
*   404 Not Found error if it's not (including if it's not a valid DOI);
*   400 Bad Request if you don't include a DOI.

A request to `/redirect/<DOI here>` will redirect you straight there instead (just like `dx.doi.org`).

Both will also accept the DOI as a parameter, so `/resolve?doi=<URL-encoded DOI here>` will behave the same as `/resolve/<DOI here>`.

## About me

My name is Jez Cope and I work in higher education, helping researchers collaborate and communicate with technology.

-   [Read my blog](http://erambler.co.uk)
-   [Find me on Twitter](http://twitter.com/jezcope)
-   [Find me on Google+](http://gplus.to/jezcope)


[DOI]: http://en.wikipedia.org/wiki/Digital_object_identifier
[code]: http://github.com/jezcope/doi2oa
