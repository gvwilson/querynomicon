# Core Features

<p id="terms"></p>

## Selecting Constant

```{data-file="select_1.sql"}
select 1;
```
```{data-file="select_1.out"}
1
```

-   `select` is a keyword
-   Normally used to select data from table…
-   …but if all we want is a constant value, we don't need to specify one
-   Semi-colon terminator is required

## Selecting All Values from Table

```{data-file="select_star.sql"}
select * from little_penguins;
```
```{data-file="select_star.out"}
Gentoo|Biscoe|51.3|14.2|218.0|5300.0|MALE
Adelie|Dream|35.7|18.0|202.0|3550.0|FEMALE
Adelie|Torgersen|36.6|17.8|185.0|3700.0|FEMALE
Chinstrap|Dream|55.8|19.8|207.0|4000.0|MALE
Adelie|Dream|38.1|18.6|190.0|3700.0|FEMALE
Adelie|Dream|36.2|17.3|187.0|3300.0|FEMALE
Adelie|Dream|39.5|17.8|188.0|3300.0|FEMALE
Gentoo|Biscoe|42.6|13.7|213.0|4950.0|FEMALE
Gentoo|Biscoe|52.1|17.0|230.0|5550.0|MALE
Adelie|Torgersen|36.7|18.8|187.0|3800.0|FEMALE
```

-   An actual [query](g:query)
-   Use `*` to mean "all columns"
-   Use <code>from <em>tablename</em></code> to specify table
-   Output format is not particularly readable

## Administrative Commands {: .aside}

```{data-file="admin_commands.sql"}
.headers on
.mode markdown
select * from little_penguins;
```
```{data-file="admin_commands.out"}
|  species  |  island   | bill_length_mm | bill_depth_mm | flipper_length_mm | body_mass_g |  sex   |
|-----------|-----------|----------------|---------------|-------------------|-------------|--------|
| Gentoo    | Biscoe    | 51.3           | 14.2          | 218.0             | 5300.0      | MALE   |
| Adelie    | Dream     | 35.7           | 18.0          | 202.0             | 3550.0      | FEMALE |
| Adelie    | Torgersen | 36.6           | 17.8          | 185.0             | 3700.0      | FEMALE |
| Chinstrap | Dream     | 55.8           | 19.8          | 207.0             | 4000.0      | MALE   |
| Adelie    | Dream     | 38.1           | 18.6          | 190.0             | 3700.0      | FEMALE |
| Adelie    | Dream     | 36.2           | 17.3          | 187.0             | 3300.0      | FEMALE |
| Adelie    | Dream     | 39.5           | 17.8          | 188.0             | 3300.0      | FEMALE |
| Gentoo    | Biscoe    | 42.6           | 13.7          | 213.0             | 4950.0      | FEMALE |
| Gentoo    | Biscoe    | 52.1           | 17.0          | 230.0             | 5550.0      | MALE   |
| Adelie    | Torgersen | 36.7           | 18.8          | 187.0             | 3800.0      | FEMALE |
```

-   `.mode markdown` and `.headers on` make the output more readable
-   These SQLite [administrative commands](g:admin_command)
    start with `.` and *aren't* part of the SQL standard
    -   PostgreSQL's special commands start with `\`
-   Each command must appear on a line of its own
-   Use `.help` for a complete list
-   And as mentioned earlier, use `.quit` to quit

## Specifying Columns

```{data-file="specify_columns.penguins.sql"}
select
    species,
    island,
    sex
from little_penguins;
```
```{data-file="specify_columns.penguins.out"}
|  species  |  island   |  sex   |
|-----------|-----------|--------|
| Gentoo    | Biscoe    | MALE   |
| Adelie    | Dream     | FEMALE |
| Adelie    | Torgersen | FEMALE |
| Chinstrap | Dream     | MALE   |
| Adelie    | Dream     | FEMALE |
| Adelie    | Dream     | FEMALE |
| Adelie    | Dream     | FEMALE |
| Gentoo    | Biscoe    | FEMALE |
| Gentoo    | Biscoe    | MALE   |
| Adelie    | Torgersen | FEMALE |
```

-   Specify column names separated by commas
    -   In any order
    -   Duplicates allowed
-   Line breaks encouraged for readability

## Sorting

```{data-file="sort.penguins.sql"}
select
    species,
    sex,
    island
from little_penguins
order by island asc, sex desc;
```
```{data-file="sort.penguins.out"}
|  species  |  sex   |  island   |
|-----------|--------|-----------|
| Gentoo    | MALE   | Biscoe    |
| Gentoo    | MALE   | Biscoe    |
| Gentoo    | FEMALE | Biscoe    |
| Chinstrap | MALE   | Dream     |
| Adelie    | FEMALE | Dream     |
| Adelie    | FEMALE | Dream     |
| Adelie    | FEMALE | Dream     |
| Adelie    | FEMALE | Dream     |
| Adelie    | FEMALE | Torgersen |
| Adelie    | FEMALE | Torgersen |
```

-   `order by` must follow `from` (which must follow `select`)
-   `asc` is ascending, `desc` is descending
    -   Default is ascending, but please specify

## Exercise {: .exercise}

Write a SQL query to select the sex and body mass columns from the `little_penguins` in that order,
sorted such that the largest body mass appears first.

## Limiting Output

-   Full dataset has 344 rows

```{data-file="limit.penguins.sql"}
select
    species,
    sex,
    island
from penguins
order by species, sex, island
limit 10;
```
```{data-file="limit.penguins.out"}
| species |  sex   |  island   |
|---------|--------|-----------|
| Adelie  |        | Dream     |
| Adelie  |        | Torgersen |
| Adelie  |        | Torgersen |
| Adelie  |        | Torgersen |
| Adelie  |        | Torgersen |
| Adelie  |        | Torgersen |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
```

-   Comments start with `--` and run to the end of the line
-   <code>limit <em>N</em></code> specifies maximum number of rows returned by query

## Paging Output

```{data-file="page.penguins.sql"}
select
    species,
    sex,
    island
from penguins
order by species, sex, island
limit 10 offset 3;
```
```{data-file="page.penguins.out"}
| species |  sex   |  island   |
|---------|--------|-----------|
| Adelie  |        | Torgersen |
| Adelie  |        | Torgersen |
| Adelie  |        | Torgersen |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
| Adelie  | FEMALE | Biscoe    |
```

-   <code>offset <em>N</em></code> must follow `limit`
-   Specifies number of rows to skip from the start of the selection
-   So this query skips the first 3 and shows the next 10

## Removing Duplicates

```{data-file="distinct.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins;
```
```{data-file="distinct.penguins.out"}
|  species  |  sex   |  island   |
|-----------|--------|-----------|
| Adelie    | MALE   | Torgersen |
| Adelie    | FEMALE | Torgersen |
| Adelie    |        | Torgersen |
| Adelie    | FEMALE | Biscoe    |
| Adelie    | MALE   | Biscoe    |
| Adelie    | FEMALE | Dream     |
| Adelie    | MALE   | Dream     |
| Adelie    |        | Dream     |
| Chinstrap | FEMALE | Dream     |
| Chinstrap | MALE   | Dream     |
| Gentoo    | FEMALE | Biscoe    |
| Gentoo    | MALE   | Biscoe    |
| Gentoo    |        | Biscoe    |
```

-   `distinct` keyword must appear right after `select`
    -   SQL was supposed to read like English
-   Shows distinct combinations
-   Blanks in `sex` column show missing data
    -   We'll talk about this in a bit

## Exercise {: .exercise}

1.  Write a SQL query to select the islands and species
    from rows 50 to 60 inclusive of the `penguins` table.
    Your result should have 11 rows.

2.  Modify your query to select distinct combinations of island and species
    from the same rows
    and compare the result to what you got in part 1.

## Filtering Results

```{data-file="filter.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins
where island = 'Biscoe';
```
```{data-file="filter.penguins.out"}
| species |  sex   | island |
|---------|--------|--------|
| Adelie  | FEMALE | Biscoe |
| Adelie  | MALE   | Biscoe |
| Gentoo  | FEMALE | Biscoe |
| Gentoo  | MALE   | Biscoe |
| Gentoo  |        | Biscoe |
```

-   <code>where <em>condition</em></code> [filters](g:filter) the rows produced by selection
-   Condition is evaluated independently for each row
-   Only rows that pass the test appear in results
-   Use single quotes for `'text data'` and double quotes for `"weird column names"`
    -   SQLite will accept double-quoted text data but [SQLFluff][sqlfluff] will complain

## Exercise {: .exercise}

1.  Write a query to select the body masses from `penguins` that are less than 3000.0 grams.

2.  Write another query to select the species and sex of penguins that weight less than 3000.0 grams.
    This shows that the columns displayed and those used in filtering are independent of each other.

## Filtering with More Complex Conditions

```{data-file="filter_and.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins
where island = 'Biscoe' and sex != 'MALE';
```
```{data-file="filter_and.penguins.out"}
| species |  sex   | island |
|---------|--------|--------|
| Adelie  | FEMALE | Biscoe |
| Gentoo  | FEMALE | Biscoe |
```

-   `and`: both sub-conditions must be true
-   `or`: either or both part must be true
-   Notice that the row for Gentoo penguins on Biscoe island with unknown (empty) sex didn't pass the test
    -   We'll talk about this in a bit

## Exercise {: .exercise}

1.  Use the `not` operator to select penguins that are *not* Gentoos.

2.  SQL's `or` is an [inclusive or](g:inclusive_or):
    it succeeds if either *or both* conditions are true.
    SQL does not provide a specific operator for [exclusive or](g:exclusive_or),
    which is true if either *but not both* conditions are true,
    but the same effect can be achieved using `and`, `or`, and `not`.
    Write a query to select penguins that are female *or* on Torgersen Island *but not both*.

## Doing Calculations

```{data-file="calculations.penguins.sql"}
select
    flipper_length_mm / 10.0,
    body_mass_g / 1000.0
from penguins
limit 3;
```
```{data-file="calculations.penguins.out"}
| flipper_length_mm / 10.0 | body_mass_g / 1000.0 |
|--------------------------|----------------------|
| 18.1                     | 3.75                 |
| 18.6                     | 3.8                  |
| 19.5                     | 3.25                 |
```

-   Can do the usual kinds of arithmetic on individual values
    -   Calculation done for each row independently
-   Column name shows the calculation done

## Renaming Columns

```{data-file="rename_columns.penguins.sql"}
select
    flipper_length_mm / 10.0 as flipper_cm,
    body_mass_g / 1000.0 as weight_kg,
    island as where_found
from penguins
limit 3;
```
```{data-file="rename_columns.penguins.out"}
| flipper_cm | weight_kg | where_found |
|------------|-----------|-------------|
| 18.1       | 3.75      | Torgersen   |
| 18.6       | 3.8       | Torgersen   |
| 19.5       | 3.25      | Torgersen   |
```

-   Use <code><em>expression</em> as <em>name</em></code> to rename
-   Give result of calculation a meaningful name
-   Can also rename columns without modifying

## Exercise {: .exercise}

Write a single query that calculates and returns:

1.  A column called `what_where` that has the species and island of each penguin
    separated by a single space.
2.  A column called `bill_ratio` that has the ratio of bill length to bill depth.

You can use the `||` operator to concatenate text to solve part 1,
or look at [the documentation for SQLite's `format()` function][sqlite_format].

## Check Understanding {: .aside}

<figure id="f:core_select_concept_map">
  <img src="core_select_concept_map.svg" alt="box and arrow diagram of concepts related to selection"/>
  <figcaption>Selection Concepts</figcaption>
</figure>

## Calculating with Missing Values

```{data-file="show_missing_values.penguins.sql"}
select
    flipper_length_mm / 10.0 as flipper_cm,
    body_mass_g / 1000.0 as weight_kg,
    island as where_found
from penguins
limit 5;
```
```{data-file="show_missing_values.penguins.out"}
| flipper_cm | weight_kg | where_found |
|------------|-----------|-------------|
| 18.1       | 3.75      | Torgersen   |
| 18.6       | 3.8       | Torgersen   |
| 19.5       | 3.25      | Torgersen   |
|            |           | Torgersen   |
| 19.3       | 3.45      | Torgersen   |
```

-   SQL uses a special value [<code>null</code>](g:null) to representing missing data
    -   Not 0 or empty string, but "I don't know"
-   Flipper length and body weight not known for one of the first five penguins
-   "I don't know" divided by 10 or 1000 is "I don't know"

## Exercise {: .exercise}

Use SQLite's `.nullvalue` command
to change the printed representation of null to the string `null`
and then re-run the previous query.
When will displaying null as `null` be easier to understand?
When might it be misleading?

## Null Equality

-   Repeated from earlier

```{data-file="filter.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins
where island = 'Biscoe';
```
```{data-file="filter.penguins.out"}
| species |  sex   | island |
|---------|--------|--------|
| Adelie  | FEMALE | Biscoe |
| Adelie  | MALE   | Biscoe |
| Gentoo  | FEMALE | Biscoe |
| Gentoo  | MALE   | Biscoe |
| Gentoo  |        | Biscoe |
```

-   If we ask for female penguins the row with the missing sex drops out

```{data-file="null_equality.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins
where island = 'Biscoe' and sex = 'FEMALE';
```
```{data-file="null_equality.penguins.out"}
| species |  sex   | island |
|---------|--------|--------|
| Adelie  | FEMALE | Biscoe |
| Gentoo  | FEMALE | Biscoe |
```

## Null Inequality

-   But if we ask for penguins that *aren't* female it drops out as well

```{data-file="null_inequality.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins
where island = 'Biscoe' and sex != 'FEMALE';
```
```{data-file="null_inequality.penguins.out"}
| species | sex  | island |
|---------|------|--------|
| Adelie  | MALE | Biscoe |
| Gentoo  | MALE | Biscoe |
```

## Ternary Logic

```{data-file="ternary_logic.penguins.sql"}
select null = null;
```
```{data-file="ternary_logic.penguins.out"}
| null = null |
|-------------|
|             |
```

-   If we don't know the left and right values, we don't know if they're equal or not
-   So the result is `null`
-   Get the same answer for `null != null`
-   [Ternary logic](g:ternary_logic)

<table>
  <tbody>
    <tr>
      <th colspan="4">equality</th>
    </tr>
    <tr>
      <th></th>
      <th>X</th>
      <th>Y</th>
      <th>null</th>
    </tr>
    <tr>
      <th>X</th>
      <td>true</td>
      <td>false</td>
      <td>null</td>
    </tr>
    <tr>
      <th>Y</th>
      <td>false</td>
      <td>true</td>
      <td>null</td>
    </tr>
    <tr>
      <th>null</th>
      <td>null</td>
      <td>null</td>
      <td>null</td>
    </tr>
  </tbody>
</table>

## Handling Null Safely

```{data-file="safe_null_equality.penguins.sql"}
select
    species,
    sex,
    island
from penguins
where sex is null;
```
```{data-file="safe_null_equality.penguins.out"}
| species | sex |  island   |
|---------|-----|-----------|
| Adelie  |     | Torgersen |
| Adelie  |     | Torgersen |
| Adelie  |     | Torgersen |
| Adelie  |     | Torgersen |
| Adelie  |     | Torgersen |
| Adelie  |     | Dream     |
| Gentoo  |     | Biscoe    |
| Gentoo  |     | Biscoe    |
| Gentoo  |     | Biscoe    |
| Gentoo  |     | Biscoe    |
| Gentoo  |     | Biscoe    |
```

-   Use `is null` and `is not null` to handle null safely
-   Other parts of SQL handle nulls specially

## Exercise {: .exercise}

1.  Write a query to find penguins whose body mass is known but whose sex is not.

2.  Write another query to find penguins whose sex is known but whose body mass is not.

## Check Understanding {: .aside}

<figure id="f:core_missing_concept_map">
  <img src="core_missing_concept_map.svg" alt="box and arrow diagram of concepts related to null values in SQL"/>
  <figcaption>Missing Value Concepts</figcaption>
</figure>

## Aggregating

```{data-file="simple_sum.penguins.sql"}
select sum(body_mass_g) as total_mass
from penguins;
```
```{data-file="simple_sum.penguins.out"}
| total_mass |
|------------|
| 1437000.0  |
```

-   [Aggregation](g:aggregation) combines many values to produce one
-   `sum` is an [aggregation function](g:aggregation_func)
-   Combines corresponding values from multiple rows

## Common Aggregation Functions

```{data-file="common_aggregations.penguins.sql"}
select
    max(bill_length_mm) as longest_bill,
    min(flipper_length_mm) as shortest_flipper,
    avg(bill_length_mm) / avg(bill_depth_mm) as weird_ratio
from penguins;
```
```{data-file="common_aggregations.penguins.out"}
| longest_bill | shortest_flipper |   weird_ratio    |
|--------------|------------------|------------------|
| 59.6         | 172.0            | 2.56087082530644 |
```

-   This actually shouldn't work:
    can't calculate maximum or average if any values are null
-   SQL does the useful thing instead of the right one

## Exercise {: .exercise}

What is the average body mass of penguins that weight more than 3000.0 grams?

## Counting

```{data-file="count_behavior.penguins.sql"}
select
    count(*) as count_star,
    count(sex) as count_specific,
    count(distinct sex) as count_distinct
from penguins;
```
```{data-file="count_behavior.penguins.out"}
| count_star | count_specific | count_distinct |
|------------|----------------|----------------|
| 344        | 333            | 2              |
```

-   `count(*)` counts rows
-   <code>count(<em>column</em>)</code> counts non-null entries in column
-   <code>count(distinct <em>column</em>)</code> counts distinct non-null entries

## Exercise {: .exercise}

How many different body masses are in the penguins dataset?

## Grouping

```{data-file="simple_group.penguins.sql"}
select avg(body_mass_g) as average_mass_g
from penguins
group by sex;
```
```{data-file="simple_group.penguins.out"}
|  average_mass_g  |
|------------------|
| 4005.55555555556 |
| 3862.27272727273 |
| 4545.68452380952 |
```

-   Put rows in [groups](g:group) based on distinct combinations of values in columns specified with `group by`
-   Then perform aggregation separately for each group
-   But which is which?

## Behavior of Unaggregated Columns

```{data-file="unaggregated_columns.penguins.sql"}
select
    sex,
    avg(body_mass_g) as average_mass_g
from penguins
group by sex;
```
```{data-file="unaggregated_columns.penguins.out"}
|  sex   |  average_mass_g  |
|--------|------------------|
|        | 4005.55555555556 |
| FEMALE | 3862.27272727273 |
| MALE   | 4545.68452380952 |
```

-   All rows in each group have the same value for `sex`, so no need to aggregate

## Arbitrary Choice in Aggregation

```{data-file="arbitrary_in_aggregation.penguins.sql"}
select
    sex,
    body_mass_g                   
from penguins
group by sex;
```
```{data-file="arbitrary_in_aggregation.penguins.out"}
|  sex   | body_mass_g |
|--------|-------------|
|        |             |
| FEMALE | 3800.0      |
| MALE   | 3750.0      |
```

-   If we don't specify how to aggregate a column,
    SQLite chooses *any arbitrary value* from the group
    -   All penguins in each group have the same sex because we grouped by that, so we get the right answer
    -   The body mass values are in the data but unpredictable
    -   A common mistake
-   Other database managers don't do this
    -   E.g., PostgreSQL complains that column must be used in an aggregation function

## Exercise {: .exercise}

Explain why the output of the previous query
has a blank line before the rows for female and male penguins.

Write a query that shows each distinct body mass in the penguin dataset
and the number of penguins that weigh that much.

## Filtering Aggregated Values

```{data-file="filter_aggregation.penguins.sql"}
select
    sex,
    avg(body_mass_g) as average_mass_g
from penguins
group by sex
having average_mass_g > 4000.0;
```
```{data-file="filter_aggregation.penguins.out"}
| sex  |  average_mass_g  |
|------|------------------|
|      | 4005.55555555556 |
| MALE | 4545.68452380952 |
```

-   Using <code>having <em>condition</em></code> instead of <code>where <em>condition</em></code> for aggregates

## Readable Output

```{data-file="readable_aggregation.penguins.sql"}
select
    sex,
    round(avg(body_mass_g), 1) as average_mass_g
from penguins
group by sex
having average_mass_g > 4000.0;
```
```{data-file="readable_aggregation.penguins.out"}
| sex  | average_mass_g |
|------|----------------|
|      | 4005.6         |
| MALE | 4545.7         |
```

-   Use <code>round(<em>value</em>, <em>decimals</em>)</code> to round off a number

## Filtering Aggregate Inputs

```{data-file="filter_aggregate_inputs.penguins.sql"}
select
    sex,
    round(
        avg(body_mass_g) filter (where body_mass_g < 4000.0),
        1
    ) as average_mass_g
from penguins
group by sex;
```
```{data-file="filter_aggregate_inputs.penguins.out"}
|  sex   | average_mass_g |
|--------|----------------|
|        | 3362.5         |
| FEMALE | 3417.3         |
| MALE   | 3729.6         |
```

-   <code>filter (where <em>condition</em>)</code> applies to *inputs*

## Exercise {: .exercise}

Write a query that uses `filter` to calculate the average body masses
of heavy penguins (those over 4500 grams)
and light penguins (those under 3500 grams)
simultaneously.
Is it possible to do this using `where` instead of `filter`?

## Check Understanding {: .aside}

<figure id="f:core_aggregate_concept_map">
  <img src="core_aggregate_concept_map.svg" alt="box and arrow diagram of concepts related to aggregation in SQL"/>
  <figcaption>Aggregation Concepts</figcaption>
</figure>

## Creating In-memory Database {: .aside}

```{data-file="in_memory_db.sh"}
sqlite3 :memory:
```

-   "Connect" to an [in-memory database](g:in_memory_db)
    -   Changes aren't saved to disk
    -   Very useful for testing (discussed later)

## Creating Tables

```{data-file="create_work_job.sql"}
create table job (
    name text not null,
    billable real not null
);
create table work (
    person text not null,
    job text not null
);
```

-   <code>create table <em>name</em></code> followed by parenthesized list of columns
-   Each column is a name, a data type, and optional extra information
    -   E.g., `not null` prevents nulls from being added
-   `.schema` is *not* standard SQL
-   SQLite has added a few things
    -   `create if not exists`
    -   upper-case keywords (SQL is case insensitive)

## Following Along {: .aside}

-   Use `work_job.db` from the zip file

## Inserting Data

```{data-file="populate_work_job.sql"}
insert into job values
('calibrate', 1.5),
('clean', 0.5);
insert into work values
('mik', 'calibrate'),
('mik', 'clean'),
('mik', 'complain'),
('po', 'clean'),
('po', 'complain'),
('tay', 'complain');
```
```{data-file="show_work_job.memory.out"}
|   name    | billable |
|-----------|----------|
| calibrate | 1.5      |
| clean     | 0.5      |
| person |    job    |
|--------|-----------|
| mik    | calibrate |
| mik    | clean     |
| mik    | complain  |
| po     | clean     |
| po     | complain  |
| tay    | complain  |
```

## Exercise {: .exercise}

Using an in-memory database,
define a table called `notes` with two text columns `author` and `note`
and then add three or four rows.
Use a query to check that the notes have been stored
and that you can (for example) select by author name.

What happens if you try to insert too many or too few values into `notes`?
What happens if you insert a number instead of a string into the `note` field?

## Updating Rows

```{data-file="update_work_job.sql"}
update work
set person = 'tae'
where person = 'tay';
```
```{data-file="show_after_update.memory.out"}
| person |    job    |
|--------|-----------|
| mik    | calibrate |
| mik    | clean     |
| mik    | complain  |
| po     | clean     |
| po     | complain  |
| tae    | complain  |
```

-   (Almost) always specify row(s) to update using `where`
    -   Otherwise update all rows in table, which is usually not wanted

## Deleting Rows

```{data-file="delete_rows.memory.sql:keep"}
delete from work
where person = 'tae';

select * from work;
```
```{data-file="delete_rows.memory.out"}
| person |    job    |
|--------|-----------|
| mik    | calibrate |
| mik    | clean     |
| mik    | complain  |
| po     | clean     |
| po     | complain  |
```

-   Again, (almost) always specify row(s) to delete using `where`

## Exercise {: .exercise}

What happens if you try to delete rows that don't exist
(e.g., all entries in `work` that refer to `juna`)?

## Backing Up

```{data-file="backing_up.memory.sql:keep"}
create table backup (
    person text not null,
    job text not null
);

insert into backup
select
    person,
    job
from work
where person = 'tae';

delete from work
where person = 'tae';

select * from backup;
```
```{data-file="backing_up.memory.out"}
| person |   job    |
|--------|----------|
| tae    | complain |
```

-   We will explore another strategy based on [tombstones](g:tombstone) below

## Exercise {: .exercise}

Saving and restoring data as text:

1.  Re-create the `notes` table in an in-memory database
    and then use SQLite's `.output` and `.dump` commands
    to save the database to a file called `notes.sql`.
    Inspect the contents of this file:
    how has your data been stored?

2.  Start a fresh SQLite session
    and load `notes.sql` using the `.read` command.
    Inspect the database using `.schema` and `select *`:
    is everything as you expected?

Saving and restoring data in binary format:

1.  Re-create the `notes` table in an in-memory database once again
    and use SQLite's `.backup` command to save it to a file called `notes.db`.
    Inspect this file using `od -c notes.db` or a text editor that can handle binary data:
    how has your data been stored?

2.  Start a fresh SQLite session
    and load `notes.db` using the `.restore` command.
    Inspect the database using `.schema` and `select *`:
    is everything as you expected?

## Check Understanding {: .aside}

<figure id="f:core_datamod_concept_map">
  <img src="core_datamod_concept_map.svg" alt="box and arrow diagram of concepts related to defining and modifying data"/>
  <figcaption>Data Definition and Modification Concepts</figcaption>
</figure>

## Combining Information

```{data-file="cross_join.memory.sql:keep"}
select *
from work cross join job;
```
```{data-file="cross_join.memory.out"}
| person |    job    |   name    | billable |
|--------|-----------|-----------|----------|
| mik    | calibrate | calibrate | 1.5      |
| mik    | calibrate | clean     | 0.5      |
| mik    | clean     | calibrate | 1.5      |
| mik    | clean     | clean     | 0.5      |
| mik    | complain  | calibrate | 1.5      |
| mik    | complain  | clean     | 0.5      |
| po     | clean     | calibrate | 1.5      |
| po     | clean     | clean     | 0.5      |
| po     | complain  | calibrate | 1.5      |
| po     | complain  | clean     | 0.5      |
| tay    | complain  | calibrate | 1.5      |
| tay    | complain  | clean     | 0.5      |
```

-   A [join](g:join) combines information from two tables
-   [cross join](g:cross_join) constructs their cross product
    -   All combinations of rows from each
-   Result isn't particularly useful: `job` and `name` values don't match
    -   I.e., the combined data has records whose parts have nothing to do with each other

## Inner Join

```{data-file="inner_join.memory.sql:keep"}
select *
from work inner join job
    on work.job = job.name;
```
```{data-file="inner_join.memory.out"}
| person |    job    |   name    | billable |
|--------|-----------|-----------|----------|
| mik    | calibrate | calibrate | 1.5      |
| mik    | clean     | clean     | 0.5      |
| po     | clean     | clean     | 0.5      |
```

-   Use <code><em>table</em>.<em>column</em></code> notation to specify columns
    -   A column can have the same name as a table
-   Use <code>on <em>condition</em></code> to specify [join condition](g:join_condition)
-   Since `complain` doesn't appear in `job.name`, none of those rows are kept

## Exercise {: .exercise}

Re-run the query shown above using `where job = name` instead of the full `table.name` notation.
Is the shortened form easier or harder to read
and more or less likely to cause errors?

## Aggregating Joined Data

```{data-file="aggregate_join.memory.sql:keep"}
select
    work.person,
    sum(job.billable) as pay
from work inner join job
    on work.job = job.name
group by work.person;
```
```{data-file="aggregate_join.memory.out"}
| person | pay |
|--------|-----|
| mik    | 2.0 |
| po     | 0.5 |
```

-   Combines ideas we've seen before
-   But Tay is missing from the table
    -   No records in the `job` table with `tay` as name
    -   So no records to be grouped and summed

## Left Join

```{data-file="left_join.memory.sql:keep"}
select *
from work left join job
    on work.job = job.name;
```
```{data-file="left_join.memory.out"}
| person |    job    |   name    | billable |
|--------|-----------|-----------|----------|
| mik    | calibrate | calibrate | 1.5      |
| mik    | clean     | clean     | 0.5      |
| mik    | complain  |           |          |
| po     | clean     | clean     | 0.5      |
| po     | complain  |           |          |
| tay    | complain  |           |          |
```

-   A [left outer join](g:left_outer_join) keeps all rows from the left table
-   Fills missing values from right table with null

## Aggregating Left Joins

```{data-file="aggregate_left_join.memory.sql:keep"}
select
    work.person,
    sum(job.billable) as pay
from work left join job
    on work.job = job.name
group by work.person;
```
```{data-file="aggregate_left_join.memory.out"}
| person | pay |
|--------|-----|
| mik    | 2.0 |
| po     | 0.5 |
| tay    |     |
```

-   That's better, but we'd like to see 0 rather than a blank

## Coalescing Values

```{data-file="coalesce.memory.sql:keep"}
select
    work.person,
    coalesce(sum(job.billable), 0.0) as pay
from work left join job
    on work.job = job.name
group by work.person;
```
```{data-file="coalesce.memory.out"}
| person | pay |
|--------|-----|
| mik    | 2.0 |
| po     | 0.5 |
| tay    | 0.0 |
```

-   <code>coalesce(<em>val1</em>, <em>val2</em>, …)</code> returns first non-null value

## Full Outer Join {: .aside}

-   [Full outer join](g:full_outer_join) is the union of
    left outer join and [right outer join](g:right_outer_join)
-   Almost the same as cross join, but consider:

```{data-file="full_outer_join.memory.sql"}
create table size (
    s text not null
);
insert into size values ('light'), ('heavy');

create table weight (
    w text not null
);

select * from size full outer join weight;
```
```{data-file="full_outer_join.memory.out"}
|   s   | w |
|-------|---|
| light |   |
| heavy |   |
```

-   A cross join would produce empty result

## Exercise {: .exercise}

Find the least time each person spent on any job.
Your output should show that `mik` and `po` each spent 0.5 hours on some job.
Can you find a way to show the name of the job as well
using the SQL you have seen so far?

## Check Understanding {: .aside}

<figure id="f:core_join_concept_map">
  <img src="core_join_concept_map.svg" alt="box and arrow diagram of concepts related to joining tables"/>
  <figcaption>Join Concepts</figcaption>
</figure>
