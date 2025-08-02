# Tools

<p id="terms"></p>

## Negating Incorrectly

-   Who doesn't calibrate?

```{data-file="negate_incorrectly.memory.sql:keep"}
select distinct person
from work
where job != 'calibrate';
```
```{data-file="negate_incorrectly.memory.out"}
| person |
|--------|
| mik    |
| po     |
| tay    |
```

-   But Mik *does* calibrate
-   Problem is that there's an entry for Mik cleaning
-   And since `'clean' != 'calibrate'`, that row is included in the results
-   We need a different approach…

## Set Membership

```{data-file="set_membership.sql:keep"}
select *
from work
where person not in ('mik', 'tay');
```
```{data-file="set_membership.out"}
| person |   job    |
|--------|----------|
| po     | clean    |
| po     | complain |
```

-   <code>in <em>values</em></code> and <code>not in <em>values</em></code> do exactly what you expect

## Subqueries

```{data-file="subquery_set.sql:keep"}
select distinct person
from work
where person not in (
    select distinct person
    from work
    where job = 'calibrate'
);
```
```{data-file="subquery_set.out"}
| person |
|--------|
| po     |
| tay    |
```

-   Use a [subquery](g:subquery) to select the people who *do* calibrate
-   Then select all the people who *aren't* in that set
-   Initially feels odd, but subqueries are useful in other ways

## Defining a Primary Key {: .aside}

-   Can use any field (or combination of fields) in a table as a [primary key](g:primary_key)
    as long as value(s) unique for each record
-   Uniquely identifies a particular record in a particular table

```{data-file="primary_key.sql"}
create table lab_equipment (
    size real not null,
    color text not null,
    num integer not null,
    primary key (size, color)
);

insert into lab_equipment values
(1.5, 'blue', 2),
(1.5, 'green', 1),
(2.5, 'blue', 1);

select * from lab_equipment;

insert into lab_equipment values
(1.5, 'green', 2);
```
```{data-file="primary_key.out"}
| size | color | num |
|------|-------|-----|
| 1.5  | blue  | 2   |
| 1.5  | green | 1   |
| 2.5  | blue  | 1   |
Runtime error near line 17: UNIQUE constraint failed: lab_equipment.size, lab_equipment.color (19)
```

## Exercise {: .exercise}

Does the `penguins` table have a primary key?
If so, what is it?
What about the `work` and `job` tables?

## Autoincrementing and Primary Keys

```{data-file="autoincrement.sql"}
create table person (
    ident integer primary key autoincrement,
    name text not null
);
insert into person values
(null, 'mik'),
(null, 'po'),
(null, 'tay');
select * from person;
insert into person values (1, 'prevented');
```
```{data-file="autoincrement.out"}
| ident | name |
|-------|------|
| 1     | mik  |
| 2     | po   |
| 3     | tay  |
Runtime error near line 12: UNIQUE constraint failed: person.ident (19)
```

-   Database [autoincrements](g:autoincrement) `ident` each time a new record is added
-   Common to use that field as the primary key
    -   Unique for each record
-   If Mik changes their name again,
    we only have to change one fact in the database
-   Downside: manual queries are harder to read (who is person 17?)

## Internal Tables {: .aside}

```{data-file="sequence_table.memory.sql:keep"}
select * from sqlite_sequence;
```
```{data-file="sequence_table.memory.out"}
|  name  | seq |
|--------|-----|
| person | 3   |
```

-   Sequence numbers are *not* reset when rows are deleted
    -   In part so that they can be used as primary keys

## Exercise {: .exercise}

Are you able to modify the values stored in `sqlite_sequence`?
In particular,
are you able to reset the values so that
the same sequence numbers are generated again?

## Altering Tables

```{data-file="alter_tables.sql:keep"}
alter table job
add ident integer not null default -1;

update job
set ident = 1
where name = 'calibrate';

update job
set ident = 2
where name = 'clean';

select * from job;
```
```{data-file="alter_tables.out"}
|   name    | billable | ident |
|-----------|----------|-------|
| calibrate | 1.5      | 1     |
| clean     | 0.5      | 2     |
```

-   Add a column after the fact
-   Since it can't be null, we have to provide a default value
    -   Really want to make it the primary key, but SQLite doesn't allow that after the fact
-   Then use `update` to modify existing records
    -   Can modify any number of records at once
    -   So be careful about `where` clause
-   An example of [data migration](g:data_migration)

## M-to-N Relationships {: .aside}

-   Relationships between entities are usually characterized as:
    -   [1-to-1](g:1_to_1):
        fields in the same record
    -   [1-to-many](g:1_to_many):
        the many have a [foreign key](g:foreign_key) referring to the one's primary key
    -   [many-to-many](g:many_to_many):
        don't know how many keys to add to records ("maximum" never is)
-   Nearly-universal solution is a [join table](g:join_table)
    -   Each record is a pair of foreign keys
    -   I.e., each record is the fact that records A and B are related

## Creating New Tables from Old

```{data-file="insert_select.sql:keep"}
create table new_work (
    person_id integer not null,
    job_id integer not null,
    foreign key (person_id) references person (ident),
    foreign key (job_id) references job (ident)
);

insert into new_work
select
    person.ident as person_id,
    job.ident as job_id
from
    (person inner join work on person.name = work.person)
    inner join job on job.name = work.job;
select * from new_work;
```
```{data-file="insert_select.out"}
| person_id | job_id |
|-----------|--------|
| 1         | 1      |
| 1         | 2      |
| 2         | 2      |
```

-   `new_work` is our join table
-   Each column refers to a record in some other table

## Removing Tables

```{data-file="drop_table.sql:keep"}
drop table work;
alter table new_work rename to work;
```
```{data-file="drop_table.out"}
CREATE TABLE job (
    ident integer primary key autoincrement,
    name text not null,
    billable real not null
);
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE person (
    ident integer primary key autoincrement,
    name text not null
);
CREATE TABLE IF NOT EXISTS "work" (
    person_id integer not null,
    job_id integer not null,
    foreign key(person_id) references person(ident),
    foreign key(job_id) references job(ident)
);
```

-   Remove the old table and rename the new one to take its place
    -   Note `if exists`
-   Please back up your data first

## Exercise {: .exercise}

1.  Reorganize the penguins database:
    1.  Make a copy of the `penguins.db` file
        so that your changes won't affect the original.
    2.  Write a SQL script that reorganizes the data into three tables:
        one for each island.
    3.  Why is organizing data like this a bad idea?

2.  Tools like [Sqitch][sqitch] can manage changes to database schemas and data
    so that they can be saved in version control
    and rolled back if they are unsuccessful.
    Translate the changes made by the scripts above into Sqitch.
    Note: this exercise may take an hour or more.

## Comparing Individual Values to Aggregates

-   Go back to the original penguins database

```{data-file="compare_individual_aggregate.penguins.sql"}
select body_mass_g
from penguins
where
    body_mass_g > (
        select avg(body_mass_g)
        from penguins
    )
limit 5;
```
```{data-file="compare_individual_aggregate.penguins.out"}
| body_mass_g |
|-------------|
| 4675.0      |
| 4250.0      |
| 4400.0      |
| 4500.0      |
| 4650.0      |
```

-   Get average body mass in subquery
-   Compare each row against that
-   Requires two scans of the data, but no way to avoid that
    -   Except calculating a running total each time a penguin is added to the table
-   Null values aren't included in the average or in the final results

## Exercise {: .exercise}

Use a subquery to find the number of penguins
that weigh the same as the lightest penguin.

## Comparing Individual Values to Aggregates Within Groups

```{data-file="compare_within_groups.penguins.sql"}
select
    penguins.species,
    penguins.body_mass_g,
    round(averaged.avg_mass_g, 1) as avg_mass_g
from penguins inner join (
    select
        species,
        avg(body_mass_g) as avg_mass_g
    from penguins
    group by species
) as averaged
    on penguins.species = averaged.species
where penguins.body_mass_g > averaged.avg_mass_g
limit 5;
```
```{data-file="compare_within_groups.penguins.out"}
| species | body_mass_g | avg_mass_g |
|---------|-------------|------------|
| Adelie  | 3750.0      | 3700.7     |
| Adelie  | 3800.0      | 3700.7     |
| Adelie  | 4675.0      | 3700.7     |
| Adelie  | 4250.0      | 3700.7     |
| Adelie  | 3800.0      | 3700.7     |
```

-   Subquery runs first to create temporary table `averaged` with average mass per species
-   Join that with `penguins`
-   Filter to find penguins heavier than average within their species

## Exercise {: .exercise}

Use a subquery to find the number of penguins
that weigh the same as the lightest penguin of the same sex and species.

## Common Table Expressions

```{data-file="common_table_expressions.penguins.sql"}
with grouped as (
    select
        species,
        avg(body_mass_g) as avg_mass_g
    from penguins
    group by species
)

select
    penguins.species,
    penguins.body_mass_g,
    round(grouped.avg_mass_g, 1) as avg_mass_g
from penguins inner join grouped
where penguins.body_mass_g > grouped.avg_mass_g
limit 5;
```
```{data-file="common_table_expressions.penguins.out"}
| species | body_mass_g | avg_mass_g |
|---------|-------------|------------|
| Adelie  | 3750.0      | 3700.7     |
| Adelie  | 3800.0      | 3700.7     |
| Adelie  | 4675.0      | 3700.7     |
| Adelie  | 4250.0      | 3700.7     |
| Adelie  | 3800.0      | 3700.7     |
```

-   Use [common table expression](g:cte) (CTE) to make queries clearer
    -   Nested subqueries quickly become difficult to understand
-   Database decides how to optimize

## Explaining Query Plans {: .aside}

```{data-file="explain_query_plan.penguins.sql"}
explain query plan
select
    species,
    avg(body_mass_g)
from penguins
group by species;
```
```{data-file="explain_query_plan.penguins.out"}
QUERY PLAN
|--SCAN penguins
`--USE TEMP B-TREE FOR GROUP BY
```

-   SQLite plans to scan every row of the table
-   It will build a temporary [B-tree data structure](g:b_tree) to group rows

## Exercise {: .exercise}

Use a CTE to find
the number of penguins
that weigh the same as the lightest penguin of the same sex and species.

## Enumerating Rows

-   Every table has a special column called `rowid`

```{data-file="rowid.penguins.sql"}
select
    rowid,
    species,
    island
from penguins
limit 5;
```
```{data-file="rowid.penguins.out"}
| rowid | species |  island   |
|-------|---------|-----------|
| 1     | Adelie  | Torgersen |
| 2     | Adelie  | Torgersen |
| 3     | Adelie  | Torgersen |
| 4     | Adelie  | Torgersen |
| 5     | Adelie  | Torgersen |
```

-   `rowid` is persistent within a session
    -   I.e., if we delete the first 5 rows we now have row IDs 6…N
-   *Do not rely on row ID*
    -   In particular, do not use it as a key

## Exercise {: .exercise}

To explore how row IDs behave:

1.  Suppose that you create a new table,
    add three rows,
    delete those rows,
    and add the same values again.
    Do you expect the row IDs of the final rows to be 1–3 or 4–6?

2.  Using an in-memory database,
    perform the steps in part 1.
    Was the result what you expected?

## Conditionals

```{data-file="if_else.penguins.sql"}
with sized_penguins as (
    select
        species,
        iif(
            body_mass_g < 3500,
            'small',
            'large'
        ) as size
    from penguins
    where body_mass_g is not null
)

select
    species,
    size,
    count(*) as num
from sized_penguins
group by species, size
order by species, num;
```
```{data-file="if_else.penguins.out"}
|  species  | size  | num |
|-----------|-------|-----|
| Adelie    | small | 54  |
| Adelie    | large | 97  |
| Chinstrap | small | 17  |
| Chinstrap | large | 51  |
| Gentoo    | large | 123 |
```

-   <code>iif(<em>condition</em>, <em>true_result</em>, <em>false_result</em>)</code>
    -   Note: `iif` with two i's
-   May feel odd to think of `if`/`else` as a function,
    but common in [vectorized](g:vectorization) calculations

## Exercise {: .exercise}

How does the result of the previous query change
if the check for null body mass is removed?
Why is the result without that check misleading?

What does each of the expressions shown below produce?
Which ones do you think actually attempt to divide by zero?

1.  `iif(0, 123, 1/0)`
1.  `iif(1, 123, 1/0)`
1.  `iif(0, 1/0, 123)`
1.  `iif(1, 1/0, 123)`

## Selecting a Case

-   What if we want small, medium, and large?
-   Can nest `iif`, but quickly becomes unreadable

```{data-file="case_when.penguins.sql"}
with sized_penguins as (
    select
        species,
        case
            when body_mass_g < 3500 then 'small'
            when body_mass_g < 5000 then 'medium'
            else 'large'
        end as size
    from penguins
    where body_mass_g is not null
)

select
    species,
    size,
    count(*) as num
from sized_penguins
group by species, size
order by species, num;
```
```{data-file="case_when.penguins.out"}
|  species  |  size  | num |
|-----------|--------|-----|
| Adelie    | small  | 54  |
| Adelie    | medium | 97  |
| Chinstrap | small  | 17  |
| Chinstrap | medium | 51  |
| Gentoo    | medium | 56  |
| Gentoo    | large  | 67  |
```

-   Evaluate `when` options in order and take first
-   Result of `case` is null if no condition is true
-   Use `else` as fallback

## Exercise {: .exercise}

Modify the query above so that
the outputs are `"penguin is small"` and `"penguin is large"`
by concatenating the string `"penguin is "` to the entire `case`
rather than to the individual `when` branches.
(This exercise shows that `case`/`when` is an [expression](g:expression)
rather than a [statement](g:statement).)

## Checking a Range

```{data-file="check_range.penguins.sql"}
with sized_penguins as (
    select
        species,
        case
            when body_mass_g between 3500 and 5000 then 'normal'
            else 'abnormal'
        end as size
    from penguins
    where body_mass_g is not null
)

select
    species,
    size,
    count(*) as num
from sized_penguins
group by species, size
order by species, num;
```
```{data-file="check_range.penguins.out"}
|  species  |   size   | num |
|-----------|----------|-----|
| Adelie    | abnormal | 54  |
| Adelie    | normal   | 97  |
| Chinstrap | abnormal | 17  |
| Chinstrap | normal   | 51  |
| Gentoo    | abnormal | 61  |
| Gentoo    | normal   | 62  |
```

-   `between` can make queries easier to read
-   But be careful of the `and` in the middle

## Exercise {: .exercise}

The expression `val between 'A' and 'Z'` is true if `val` is `'M'` (upper case)
but false if `val` is `'m'` (lower case).
Rewrite the expression using [SQLite's built-in scalar functions][sqlite_function]
so that it is true in both cases.

| name      | purpose |
| --------- | ------- |
| `substr`  | Get substring given starting point and length |
| `trim`    | Remove characters from beginning and end of string |
| `ltrim`   | Remove characters from beginning of string |
| `rtrim`   | Remove characters from end of string |
| `length`  | Length of string |
| `replace` | Replace occurrences of substring with another string |
| `upper`   | Return upper-case version of string |
| `lower`   | Return lower-case version of string |
| `instr`   | Find location of first occurrence of substring (returns 0 if not found) |

## Yet Another Database {: .aside}

-   [Entity-relationship diagram](g:er_diagram) (ER diagram) shows relationships between tables
-   Like everything to do with databases, there are lots of variations

<figure id="tools_assays_tables">
  <img src="tools_assays_tables.svg" alt="table-level diagram of assay database showing primary and foreign key relationships"/>
  <figcaption>Figure 1: Assay Database Table Diagram</figcaption>
</figure>

<figure id="assays_er">
  <img src="tools_assays_er.svg" alt="entity-relationship diagram showing logical structure of assay database"/>
  <figcaption>Figure 2: Assay ER Diagram</figcaption>
</figure>

```{data-file="assay_staff.assays.sql"}
select * from staff;
```
```{data-file="assay_staff.assays.out"}
| ident | personal |  family   | dept | age |
|-------|----------|-----------|------|-----|
| 1     | Kartik   | Gupta     |      | 46  |
| 2     | Divit    | Dhaliwal  | hist | 34  |
| 3     | Indrans  | Sridhar   | mb   | 47  |
| 4     | Pranay   | Khanna    | mb   | 51  |
| 5     | Riaan    | Dua       |      | 23  |
| 6     | Vedika   | Rout      | hist | 45  |
| 7     | Abram    | Chokshi   | gen  | 23  |
| 8     | Romil    | Kapoor    | hist | 38  |
| 9     | Ishaan   | Ramaswamy | mb   | 35  |
| 10    | Nitya    | Lal       | gen  | 52  |
```

## Exercise {: .exercise}

Draw a table diagram and an ER diagram to represent the following database:

-   `person` has `id` and `full_name`
-   `course` has `id` and `name`
-   `section` has `course_id`, `start_date`, and `end_date`
-   `instructor` has `person_id` and `section_id`
-   `student` has `person_id`, `section_id`, and `status`

## Pattern Matching

```{data-file="like_glob.assays.sql"}
select
    personal,
    family
from staff
where personal like '%ya%';
```
```{data-file="like_glob.assays.out"}
| personal | family |
|----------|--------|
| Nitya    | Lal    |
```

-   `like` is the original SQL pattern matcher
    -   `%` matches zero or more characters at the start or end of a string
    -   Case insensitive by default
-   `glob` supports Unix-style wildcards

## Exercise {: .exercise}

Rewrite the pattern-matching query shown above using `glob`.

## Selecting First and Last Rows

```{data-file="union_all.assays.sql"}
select * from (
    select * from (select * from experiment order by started asc limit 5)
    union all
    select * from (select * from experiment order by started desc limit 5)
)
order by started asc;
```
```{data-file="union_all.assays.out"}
| ident |    kind     |  started   |   ended    |
|-------|-------------|------------|------------|
| 17    | trial       | 2023-01-29 | 2023-01-30 |
| 35    | calibration | 2023-01-30 | 2023-01-30 |
| 36    | trial       | 2023-02-02 | 2023-02-03 |
| 25    | trial       | 2023-02-12 | 2023-02-14 |
| 2     | calibration | 2023-02-14 | 2023-02-14 |
| 40    | calibration | 2024-01-21 | 2024-01-21 |
| 12    | trial       | 2024-01-26 | 2024-01-28 |
| 44    | trial       | 2024-01-27 | 2024-01-29 |
| 34    | trial       | 2024-02-01 | 2024-02-02 |
| 14    | calibration | 2024-02-03 | 2024-02-03 |
```

-   `union all` combines records
    -   Keeps duplicates: `union` on its own only keeps unique records
    -   Which is more work but sometimes more useful
-   Yes, it feels like the extra `select * from` should be unnecessary

## Exercise {: .exercise}

Write a query whose result includes two rows for each Adelie penguin
in the `penguins` database.
How can you check that your query is working correctly?

## Intersection

```{data-file="intersect.assays.sql"}
select
    personal,
    family,
    dept,
    age
from staff
where dept = 'mb'
intersect
select
    personal,
    family,
    dept,
    age from staff
where age < 50;
```
```{data-file="intersect.assays.out"}
| personal |  family   | dept | age |
|----------|-----------|------|-----|
| Indrans  | Sridhar   | mb   | 47  |
| Ishaan   | Ramaswamy | mb   | 35  |
```

-   Rows involved must have the same structure
-   Intersection usually used when pulling values from different sources
    -   In the query above, would be clearer to use `where`

## Exercise {: .exercise}

Use `intersect` to find all Adelie penguins that weigh more than 4000 grams.
How can you check that your query is working correctly?

Use `explain query plan` to compare the `intersect`-based query you just wrote
with one that uses `where`.
Which query looks like it will be more efficient?
Why do you believe this?

## Exclusion

```{data-file="except.assays.sql"}
select
    personal,
    family,
    dept,
    age
from staff
where dept = 'mb'
except
    select
        personal,
        family,
        dept,
        age from staff
    where age < 50;
```
```{data-file="except.assays.out"}
| personal | family | dept | age |
|----------|--------|------|-----|
| Pranay   | Khanna | mb   | 51  |
```

-   Again, tables must have same structure
    -   And this would be clearer with `where`
-   SQL operates on sets, not tables, except where it doesn't

## Exercise {: .exercise}

Use `exclude` to find all Gentoo penguins that *aren't* male.
How can you check that your query is working correctly?

## Random Numbers and Why Not

```{data-file="random_numbers.assays.sql"}
with decorated as (
    select random() as rand,
    personal || ' ' || family as name
    from staff
)

select
    rand,
    abs(rand) % 10 as selector,
    name
from decorated
where selector < 5;
```
```{data-file="random_numbers.assays.out"}
|         rand         | selector |      name       |
|----------------------|----------|-----------------|
| -5088363674211922423 | 0        | Divit Dhaliwal  |
| 6557666280550701355  | 1        | Indrans Sridhar |
| -2149788664940846734 | 3        | Pranay Khanna   |
| -3941247926715736890 | 8        | Riaan Dua       |
| -3101076015498625604 | 5        | Vedika Rout     |
| -7884339441528700576 | 4        | Abram Chokshi   |
| -2718521057113461678 | 4        | Romil Kapoor    |
```

-   There is no way to seed SQLite's random number generator
-   Which means there is no way to reproduce its pseudo-random sequences
-   Which means you should *never* use it
    -   How are you going to debug something you can't re-run?

## Exercise {: .exercise}

Write a query that:

-   uses a CTE to create 1000 random numbers between 0 and 10 inclusive;

-   uses a second CTE to calculate their mean; and

-   uses a third CTE and [SQLite's built-in math functions][sqlite_math]
    to calculate their standard deviation.

## Creating an Index

```{data-file="create_use_index.sql"}
explain query plan
select filename
from plate
where filename like '%07%';

create index plate_file on plate(filename);

explain query plan
select filename
from plate
where filename like '%07%';
```
```{data-file="create_use_index.out"}
QUERY PLAN
`--SCAN plate USING COVERING INDEX sqlite_autoindex_plate_1
QUERY PLAN
`--SCAN plate USING COVERING INDEX plate_file
```

-   An [index](g:index) is an auxiliary data structure that enables faster access to records
    -   Spend storage space to buy speed
-   Don't have to mention it explicitly in queries
    -   Database manager will use it automatically
-   Unlike primary keys, SQLite supports defining indexes after the fact

## Generating Sequences

```{data-file="generate_sequence.assays.sql"}
select value from generate_series(1, 5);
```
```{data-file="generate_sequence.assays.out"}
| value |
|-------|
| 1     |
| 2     |
| 3     |
| 4     |
| 5     |
```

-   A (non-standard) [table-valued function](g:table_valued_func)

## Generating Sequences Based on Data

```{data-file="data_range_sequence.memory.sql"}
create table temp (
    num integer not null
);
insert into temp values (1), (5);
select value from generate_series (
    (select min(num) from temp),
    (select max(num) from temp)
);
```
```{data-file="data_range_sequence.memory.out"}
| value |
|-------|
| 1     |
| 2     |
| 3     |
| 4     |
| 5     |
```

-   Must have the parentheses around the `min` and `max` selections to keep SQLite happy

## Generating Sequences of Dates

```{data-file="date_sequence.assays.sql"}
select date((select julianday(min(started)) from experiment) + value) as some_day
from (
    select value from generate_series(
        (select 0),
        (select julianday(max(started)) - julianday(min(started)) from experiment)
    )
)
limit 5;
```
```{data-file="date_sequence.assays.out"}
|  some_day  |
|------------|
| 2023-01-29 |
| 2023-01-30 |
| 2023-01-31 |
| 2023-02-01 |
| 2023-02-02 |
```

-   SQLite represents dates as YYYY-MM-DD strings
    or as Julian days or as Unix milliseconds or…
    -   Julian days is fractional number of days since November 24, 4714 BCE
-   `julianday` and `date` convert back and forth
-   `julianday` is specific to SQLite
    -   Other databases have their own date handling functions

## Counting Experiments Started per Day Without Gaps

```{data-file="experiments_per_day.assays.sql"}
with
-- complete sequence of days with 0 as placeholder for number of experiments
all_days as (
    select
        date((select julianday(min(started)) from experiment) + value) as some_day,
        0 as zeroes
    from (
        select value from generate_series(
            (select 0),
            (select count(*) - 1 from experiment)
        )
    )
),

-- sequence of actual days with actual number of experiments started
actual_days as (
    select
        started,
        count(started) as num_exp
    from experiment
    group by started
)

-- combined by joining on day and taking actual number (if available) or zero
select
    all_days.some_day as day,
    coalesce(actual_days.num_exp, all_days.zeroes) as num_exp
from
    all_days left join actual_days on all_days.some_day = actual_days.started
limit 5;
```
```{data-file="experiments_per_day.assays.out"}
|    day     | num_exp |
|------------|---------|
| 2023-01-29 | 1       |
| 2023-01-30 | 1       |
| 2023-01-31 | 0       |
| 2023-02-01 | 0       |
| 2023-02-02 | 1       |
```

## Exercise {: .exercise}

What does the expression `date('now', 'start of month', '+1 month', '-1 day')` produce?
(You may find [the documentation on SQLite's date and time functions][sqlite_datetime] helpful.)

## Self Join

```{data-file="self_join.assays.sql"}
with person as (
    select
        ident,
        personal || ' ' || family as name
    from staff
)

select
    left_person.name,
    right_person.name
from person as left_person inner join person as right_person
limit 10;
```
```{data-file="self_join.assays.out"}
|     name     |       name       |
|--------------|------------------|
| Kartik Gupta | Kartik Gupta     |
| Kartik Gupta | Divit Dhaliwal   |
| Kartik Gupta | Indrans Sridhar  |
| Kartik Gupta | Pranay Khanna    |
| Kartik Gupta | Riaan Dua        |
| Kartik Gupta | Vedika Rout      |
| Kartik Gupta | Abram Chokshi    |
| Kartik Gupta | Romil Kapoor     |
| Kartik Gupta | Ishaan Ramaswamy |
| Kartik Gupta | Nitya Lal        |
```

-   Join a table to itself
    -   Use `as` to create [aliases](g:alias) for copies of tables to distinguish them
    -   Nothing special about the names `left` and `right`
-   Get all n^2 pairs, including person with themself

## Generating Unique Pairs

```{data-file="unique_pairs.assays.sql"}
with person as (
    select
        ident,
        personal || ' ' || family as name
    from staff
)

select
    left_person.name,
    right_person.name
from person as left_person inner join person as right_person
on left_person.ident < right_person.ident
where left_person.ident <= 4 and right_person.ident <= 4;
```
```{data-file="unique_pairs.assays.out"}
|      name       |      name       |
|-----------------|-----------------|
| Kartik Gupta    | Divit Dhaliwal  |
| Kartik Gupta    | Indrans Sridhar |
| Kartik Gupta    | Pranay Khanna   |
| Divit Dhaliwal  | Indrans Sridhar |
| Divit Dhaliwal  | Pranay Khanna   |
| Indrans Sridhar | Pranay Khanna   |
```

-   `left.ident < right.ident` ensures distinct pairs without duplicates
    -   Query uses `left.ident <= 4 and right.ident <= 4` to shorten output
-   Quick check: n(n-1)/2 pairs

## Filtering Pairs

```{data-file="filter_pairs.assays.sql"}
with
person as (
    select
        ident,
        personal || ' ' || family as name
    from staff
),

together as (
    select
        left_perf.staff as left_staff,
        right_perf.staff as right_staff
    from performed as left_perf inner join performed as right_perf
        on left_perf.experiment = right_perf.experiment
    where left_staff < right_staff
)

select
    left_person.name as person_1,
    right_person.name as person_2
from person as left_person inner join person as right_person join together
    on left_person.ident = left_staff and right_person.ident = right_staff;
```
```{data-file="filter_pairs.assays.out"}
|    person_1     |     person_2     |
|-----------------|------------------|
| Kartik Gupta    | Vedika Rout      |
| Pranay Khanna   | Vedika Rout      |
| Indrans Sridhar | Romil Kapoor     |
| Abram Chokshi   | Ishaan Ramaswamy |
| Pranay Khanna   | Vedika Rout      |
| Kartik Gupta    | Abram Chokshi    |
| Abram Chokshi   | Romil Kapoor     |
| Kartik Gupta    | Divit Dhaliwal   |
| Divit Dhaliwal  | Abram Chokshi    |
| Pranay Khanna   | Ishaan Ramaswamy |
| Indrans Sridhar | Romil Kapoor     |
| Kartik Gupta    | Ishaan Ramaswamy |
| Kartik Gupta    | Nitya Lal        |
| Kartik Gupta    | Abram Chokshi    |
| Pranay Khanna   | Romil Kapoor     |
```

## Existence and Correlated Subqueries

```{data-file="correlated_subquery.assays.sql"}
select
    name,
    building
from department
where
    exists (
        select 1
        from staff
        where dept = department.ident
    )
order by name;
```
```{data-file="correlated_subquery.assays.out"}
|       name        |     building     |
|-------------------|------------------|
| Genetics          | Chesson          |
| Histology         | Fashet Extension |
| Molecular Biology | Chesson          |
```

-   Endocrinology is missing from the list
-   `select 1` could equally be `select true` or any other value
-   A [correlated subquery](g:correlated_subquery) depends on a value from the outer query
    -   Equivalent to nested loop

## Nonexistence

```{data-file="nonexistence.assays.sql"}
select
    name,
    building
from department
where
    not exists (
        select 1
        from staff
        where dept = department.ident
    )
order by name;
```
```{data-file="nonexistence.assays.out"}
|     name      | building |
|---------------|----------|
| Endocrinology | TGVH     |
```

## Exercise {: .exercise}

Can you rewrite the previous query using `exclude`?
If so, is your new query easier to understand?
If the query cannot be rewritten, why not?

## Avoiding Correlated Subqueries {: .aside}

```{data-file="avoid_correlated_subqueries.assays.sql"}
select distinct
    department.name as name,
    department.building as building
from department inner join staff
    on department.ident = staff.dept
order by name;
```
```{data-file="avoid_correlated_subqueries.assays.out"}
|       name        |     building     |
|-------------------|------------------|
| Genetics          | Chesson          |
| Histology         | Fashet Extension |
| Molecular Biology | Chesson          |
```

-   The join might or might not be faster than the correlated subquery
-   Hard to find unstaffed departments without either `not exists` or `count` and a check for 0

## Lead and Lag

```{data-file="lead_lag.assays.sql"}
with ym_num as (
    select
        strftime('%Y-%m', started) as ym,
        count(*) as num
    from experiment
    group by ym
)

select
    ym,
    lag(num) over (order by ym) as prev_num,
    num,
    lead(num) over (order by ym) as next_num
from ym_num
order by ym;
```
```{data-file="lead_lag.assays.out"}
|   ym    | prev_num | num | next_num |
|---------|----------|-----|----------|
| 2023-01 |          | 2   | 5        |
| 2023-02 | 2        | 5   | 5        |
| 2023-03 | 5        | 5   | 1        |
| 2023-04 | 5        | 1   | 6        |
| 2023-05 | 1        | 6   | 5        |
| 2023-06 | 6        | 5   | 3        |
| 2023-07 | 5        | 3   | 2        |
| 2023-08 | 3        | 2   | 4        |
| 2023-09 | 2        | 4   | 6        |
| 2023-10 | 4        | 6   | 4        |
| 2023-12 | 6        | 4   | 5        |
| 2024-01 | 4        | 5   | 2        |
| 2024-02 | 5        | 2   |          |
```

-   Use `strftime` to extract year and month
    -   Clumsy, but date/time handling is not SQLite's strong point
-   Use [window functions](g:window_func) `lead` and `lag` to shift values
    -   Unavailable values at the top or bottom are null

## Boundaries {: .aside}

-   [Documentation on SQLite's window functions][sqlite_window] describes
    three frame types and five kinds of frame boundary
-   It feels very ad hoc, but so does the real world

## Windowing Functions

```{data-file="window_functions.assays.sql"}
with ym_num as (
    select
        strftime('%Y-%m', started) as ym,
        count(*) as num
    from experiment
    group by ym
)

select
    ym,
    num,
    sum(num) over (order by ym) as num_done,
    (sum(num) over (order by ym) * 1.00) / (select sum(num) from ym_num) as completed_progress, 
    cume_dist() over (order by ym) as linear_progress
from ym_num
order by ym;
```
```{data-file="window_functions.assays.out"}
|   ym    | num | num_done | completed_progress |  linear_progress   |
|---------|-----|----------|--------------------|--------------------|
| 2023-01 | 2   | 2        | 0.04               | 0.0769230769230769 |
| 2023-02 | 5   | 7        | 0.14               | 0.153846153846154  |
| 2023-03 | 5   | 12       | 0.24               | 0.230769230769231  |
| 2023-04 | 1   | 13       | 0.26               | 0.307692307692308  |
| 2023-05 | 6   | 19       | 0.38               | 0.384615384615385  |
| 2023-06 | 5   | 24       | 0.48               | 0.461538461538462  |
| 2023-07 | 3   | 27       | 0.54               | 0.538461538461538  |
| 2023-08 | 2   | 29       | 0.58               | 0.615384615384615  |
| 2023-09 | 4   | 33       | 0.66               | 0.692307692307692  |
| 2023-10 | 6   | 39       | 0.78               | 0.769230769230769  |
| 2023-12 | 4   | 43       | 0.86               | 0.846153846153846  |
| 2024-01 | 5   | 48       | 0.96               | 0.923076923076923  |
| 2024-02 | 2   | 50       | 1.0                | 1.0                |
```

-   `sum() over` does a running total
-   `cume_dist()` is fraction *of rows seen so far*
-   So `num_done` column is number of experiments done…
-   …`completed_progress` is the fraction of experiments done…
-   …and `linear_progress` is the fraction of time passed

## Explaining Another Query Plan {: .aside}

```{data-file="explain_window_function.assays.sql"}
explain query plan
with ym_num as (
    select
        strftime('%Y-%m', started) as ym,
        count(*) as num
    from experiment
    group by ym
)
select
    ym,
    num,
    sum(num) over (order by ym) as num_done,
    cume_dist() over (order by ym) as progress
from ym_num
order by ym;
```
```{data-file="explain_window_function.assays.out"}
QUERY PLAN
|--CO-ROUTINE (subquery-3)
|  |--CO-ROUTINE (subquery-4)
|  |  |--CO-ROUTINE ym_num
|  |  |  |--SCAN experiment
|  |  |  `--USE TEMP B-TREE FOR GROUP BY
|  |  |--SCAN ym_num
|  |  `--USE TEMP B-TREE FOR ORDER BY
|  `--SCAN (subquery-4)
`--SCAN (subquery-3)
```

-   Becomes useful…eventually

## Partitioned Windows

```{data-file="partition_window.assays.sql"}
with y_m_num as (
    select
        strftime('%Y', started) as year,
        strftime('%m', started) as month,
        count(*) as num
    from experiment
    group by year, month
)

select
    year,
    month,
    num,
    sum(num) over (partition by year order by month) as num_done
from y_m_num
order by year, month;
```
```{data-file="partition_window.assays.out"}
| year | month | num | num_done |
|------|-------|-----|----------|
| 2023 | 01    | 2   | 2        |
| 2023 | 02    | 5   | 7        |
| 2023 | 03    | 5   | 12       |
| 2023 | 04    | 1   | 13       |
| 2023 | 05    | 6   | 19       |
| 2023 | 06    | 5   | 24       |
| 2023 | 07    | 3   | 27       |
| 2023 | 08    | 2   | 29       |
| 2023 | 09    | 4   | 33       |
| 2023 | 10    | 6   | 39       |
| 2023 | 12    | 4   | 43       |
| 2024 | 01    | 5   | 5        |
| 2024 | 02    | 2   | 7        |
```

-   `partition by` creates groups
-   So this counts experiments started since the beginning of each year

## Exercise {: .exercise}

Create a query that:

1.  finds the unique weights of the penguins in the `penguins` database;

2.  sorts them;

3.  finds the difference between each successive distinct weight; and

4.  counts how many times each unique difference appears.
