# Contributing

Contributions are very welcome.
Please file issues or submit pull requests in our GitHub repository.
All contributors will be acknowledged.

## In Brief

-   Use `uv venv` and `uv pip install -r pyproject.toml`
    to install the packages required by the helper tools and Python examples.

-   The source files for examples are in their section directories
    along with captured output in `.out` files.

-   `Makefile` contains the commands used to re-run each example.
    If you add a new example,
    please add a corresponding rule in `Makefile`.

-   Use a level-2 heading for each sub-topic.
    Use `{: .aside}` for an aside
    or `{: .exercise}` for exercise.

-   Please create SVG diagrams using [draw.io][draw_io].
    Please use 14-point Helvetica for text,
    solid 1-point black lines,
    and unfilled objects.

## Labels

| Name             | Description                  | Color   |
| ---------------- | ---------------------------- | ------- |
| change           | something different          | #FBCA04 |
| feature          | new feature                  | #B60205 |
| fix              | something broken             | #5319E7 |
| good first issue | newcomers are always welcome | #D4C5F9 |
| talk             | question or discussion       | #0E8A16 |
| task             | one-off task                 | #1D76DB |

Please use [Conventional Commits][conventional] style for pull requests
by using `change:`, `feature:`, `fix:`, or `task:` as the first word
in the title of the commit message.
You may also use `publish:` if the PR just rebuilds the HTML version of the lesson.

## FAQ

Why SQL?
:   Because if you dig down far enough,
    almost every data science project sits on top of a relational database.
    ([Jon Udell][udell_jon] once called [PostgreSQL][postgresql]
    "an operating system for data science".)
    SQL's relational model has also been a powerful influence
    on dataframe libraries like [the tidyverse][tidyverse],
    [Pandas][pandas],
    and [Polars][polars];
    understanding the former therefore helps people understand the latter.

Why [McCole][mccole]?
:   The first version of this tutorial used [Jekyll][jekyll]
    because it is the default for [GitHub Pages][ghp]
    and because its frustrating limitations would discourage contributors
    from messing around with the template instead of writing content.
    However,
    those limitations proved more frustrating than anticipated:
    in particular,
    very few data scientists speak Ruby,
    so previewing changes locally required them to install and use
    yet another language framework.

Why Make?
:   It runs everywhere,
    no other build tool is a clear successor,
    and,
    like Jekyll,
    it's uncomfortable enough to use that people won't be tempted to fiddle with it
    when they could be writing.

Why hand-drawn figures rather than [Graphviz][graphviz] or [Mermaid][mermaid]?
:   Because it's faster to Just Effing Draw than it is
    to try to tweak layout parameters for text-to-diagram systems.
    If you really want to make developers' lives better,
    build a diff-and-merge tool for SVG:
    programmers shouldn't have to use punchcard-compatible data formats in the 21st Century
    just to get the benefits of version control.

Why make this tutorial freely available?
:   Because if we all give a little, we all get a lot.

## Colophon

-   The CSS files used to style code were obtained from [highlight-css][highlight_css];
    legibility was checked using [WebAIM WAVE][wave].

-   Diagrams were created with the desktop version of [draw.io][draw_io].

-   The site is hosted on [GitHub Pages][ghp].

-   Thanks to the authors of [BeautifulSoup][bs4],
    [html5validator][html5validator],
    [ruff][ruff],
    and all the other software used in this project.
    If we all give a little,
    we all get a lot.

[bs4]: https://pypi.org/project/beautifulsoup4/
[conventional]: https://www.conventionalcommits.org/
[draw_io]: https://www.drawio.com/
[ghp]: https://pages.github.com/
[highlight_css]: https://numist.github.io/highlight-css/
[html5validator]: https://pypi.org/project/html5validator/
[graphviz]: https://graphviz.org/
[jekyll]: https://jekyllrb.com/
[mccole]: https://pypi.org/project/mccole/
[mermaid]: https://mermaid.js.org/
[pandas]: https://pandas.pydata.org/
[polars]: https://pola.rs/
[postgresql]: https://www.postgresql.org/
[ruff]: https://pypi.org/project/ruff/
[tidyverse]: https://www.tidyverse.org/
[udell_jon]: https://blog.jonudell.net/
[wave]: https://wave.webaim.org/
