# Advanced Features

<p id="terms"></p>

## Blobs

```{data-file="blob.memory.sql"}
create table images (
    name text not null,
    content blob
);

insert into images (name, content) values
('biohazard', readfile('img/biohazard.png')),
('crush', readfile('img/crush.png')),
('fire', readfile('img/fire.png')),
('radioactive', readfile('img/radioactive.png')),
('tripping', readfile('img/tripping.png'));

select
    name,
    length(content)
from images;
```
```{data-file="blob.memory.out"}
|    name     | length(content) |
|-------------|-----------------|
| biohazard   | 19629           |
| crush       | 15967           |
| fire        | 18699           |
| radioactive | 16661           |
| tripping    | 17208           |
```

-   A [blob](g:blob) is a binary large object
    -   Bytes in, bytes out…
-   If you think that's odd, check out [Fossil][fossil]

## Exercise {: .exercise}

Modify the query shown above to select the value of `content`
rather than its length.
How intelligible is the output?
Does using SQLite's `hex()` function make it any more readable?

## Yet Another Database {: .aside}

```{data-file="lab_log_db.sh"}
sqlite3 db/lab_log.db
```
```{data-file="lab_log_schema.lab_log.sql"}
.schema
```
```{data-file="lab_log_schema.lab_log.out"}
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE person(
       ident            integer primary key autoincrement,
       details          text not null
);
CREATE TABLE machine(
       ident            integer primary key autoincrement,
       name             text not null,
       details          text not null
);
CREATE TABLE usage(
       ident            integer primary key autoincrement,
       log              text not null
);
```

## Storing JSON

```{data-file="json_in_table.lab_log.sql"}
select * from machine;
```
```{data-file="json_in_table.lab_log.out"}
| ident |      name      |                         details                         |
|-------|----------------|---------------------------------------------------------|
| 1     | WY401          | {"acquired": "2023-05-01"}                              |
| 2     | Inphormex      | {"acquired": "2021-07-15", "refurbished": "2023-10-22"} |
| 3     | AutoPlate 9000 | {"note": "needs software update"}                       |
```

-   Store heterogeneous data as [JSON](g:json)-formatted text
    (with double-quoted strings)
    -   Database parses the text each time it is queried,
        so performance can be an issue
-   Can alternatively store as blob (`jsonb`)
    -   Can't view it directly
    -   But more efficient

## Select Fields from JSON

```{data-file="json_field.lab_log.sql"}
select
    details->'$.acquired' as single_arrow,
    details->>'$.acquired' as double_arrow
from machine;
```
```{data-file="json_field.lab_log.out"}
| single_arrow | double_arrow |
|--------------|--------------|
| "2023-05-01" | 2023-05-01   |
| "2021-07-15" | 2021-07-15   |
|              |              |
```

-   Single arrow `->` returns JSON representation of result
-   Double arrow `->>` returns SQL text, integer, real, or null
-   Left side is column
-   Right side is [path expression](g:path_expression)
    -   Start with `$` (meaning "root")
    -   Fields separated by `.`

## Exercise {: .exercise}

Write a query that selects the year from the `"refurbished"` field
of the JSON data associated with the Inphormex plate reader.

## JSON Array Access

```{data-file="json_array.lab_log.sql"}
select
    ident,
    json_array_length(log->'$') as length,
    log->'$[0]' as first
from usage;
```
```{data-file="json_array.lab_log.out"}
| ident | length |                            first                             |
|-------|--------|--------------------------------------------------------------|
| 1     | 4      | {"machine":"Inphormex","person":["Gabrielle","Dub\u00e9"]}   |
| 2     | 5      | {"machine":"Inphormex","person":["Marianne","Richer"]}       |
| 3     | 2      | {"machine":"sterilizer","person":["Josette","Villeneuve"]}   |
| 4     | 1      | {"machine":"sterilizer","person":["Maude","Goulet"]}         |
| 5     | 2      | {"machine":"AutoPlate 9000","person":["Brigitte","Michaud"]} |
| 6     | 1      | {"machine":"sterilizer","person":["Marianne","Richer"]}      |
| 7     | 3      | {"machine":"WY401","person":["Maude","Goulet"]}              |
| 8     | 1      | {"machine":"AutoPlate 9000"}                                 |
```

-   SQLite and other database managers have many [JSON manipulation functions][sqlite_json]
-   `json_array_length` gives number of elements in selected array
-   Subscripts start with 0
-   Characters outside 7-bit ASCII represented as Unicode escapes

## Unpacking JSON Arrays

```{data-file="json_unpack.lab_log.sql"}
select
    ident,
    json_each.key as key,
    json_each.value as value
from usage, json_each(usage.log)
limit 10;
```
```{data-file="json_unpack.lab_log.out"}
| ident | key |                            value                             |
|-------|-----|--------------------------------------------------------------|
| 1     | 0   | {"machine":"Inphormex","person":["Gabrielle","Dub\u00e9"]}   |
| 1     | 1   | {"machine":"Inphormex","person":["Gabrielle","Dub\u00e9"]}   |
| 1     | 2   | {"machine":"WY401","person":["Gabrielle","Dub\u00e9"]}       |
| 1     | 3   | {"machine":"Inphormex","person":["Gabrielle","Dub\u00e9"]}   |
| 2     | 0   | {"machine":"Inphormex","person":["Marianne","Richer"]}       |
| 2     | 1   | {"machine":"AutoPlate 9000","person":["Marianne","Richer"]}  |
| 2     | 2   | {"machine":"sterilizer","person":["Marianne","Richer"]}      |
| 2     | 3   | {"machine":"AutoPlate 9000","person":["Monique","Marcotte"]} |
| 2     | 4   | {"machine":"sterilizer","person":["Marianne","Richer"]}      |
| 3     | 0   | {"machine":"sterilizer","person":["Josette","Villeneuve"]}   |
```

-   `json_each` is another table-valued function
-   Use <code>json_each.<em>name</em></code> to get properties of unpacked array

## Exercise {: .exercise}

Write a query that counts how many times each person appears
in the first log entry associated with any piece of equipment.

## Selecting the Last Element of an  Array

```{data-file="json_array_last.lab_log.sql"}
select
    ident,
    log->'$[#-1].machine' as final
from usage
limit 5;
```
```{data-file="json_array_last.lab_log.out"}
| ident |    final     |
|-------|--------------|
| 1     | "Inphormex"  |
| 2     | "sterilizer" |
| 3     | "Inphormex"  |
| 4     | "sterilizer" |
| 5     | "sterilizer" |
```

## Modifying JSON

```{data-file="json_modify.lab_log.sql"}
select
    ident,
    name,
    json_set(details, '$.sold', json_quote('2024-01-25')) as updated
from machine;
```
```{data-file="json_modify.lab_log.out"}
| ident |      name      |                           updated                            |
|-------|----------------|--------------------------------------------------------------|
| 1     | WY401          | {"acquired":"2023-05-01","sold":"2024-01-25"}                |
| 2     | Inphormex      | {"acquired":"2021-07-15","refurbished":"2023-10-22","sold":" |
|       |                | 2024-01-25"}                                                 |
| 3     | AutoPlate 9000 | {"note":"needs software update","sold":"2024-01-25"}         |
```

-   Updates the in-memory copy of the JSON, *not* the database record
-   Please use `json_quote` rather than trying to format JSON with string operations

## Exercise {: .exercise}

As part of cleaning up the lab log database,
replace the machine names in the JSON records in `usage`
with the corresponding machine IDs from the `machine` table.

## Refreshing the Penguins Database {: .aside}

```{data-file="count_penguins.penguins.sql"}
select
    species,
    count(*) as num
from penguins
group by species;
```
```{data-file="count_penguins.penguins.out"}
|  species  | num |
|-----------|-----|
| Adelie    | 152 |
| Chinstrap | 68  |
| Gentoo    | 124 |
```

-   We will restore full database after each example

## Tombstones

```{data-file="make_active.sql"}
alter table penguins
add active integer not null default 1;

update penguins
set active = iif(species = 'Adelie', 0, 1);
```
```{data-file="active_penguins.sql:keep"}
select
    species,
    count(*) as num
from penguins
where active
group by species;
```
```{data-file="active_penguins.out"}
|  species  | num |
|-----------|-----|
| Chinstrap | 68  |
| Gentoo    | 124 |
```

-   Use a tombstone to mark (in)active records
-   Every query must now include it

## Importing CSV Data {: .aside}

-   SQLite and most other database managers have tools for importing and exporting [CSV](g:csv)
-   In SQLite:
    -   Define table
    -   Import data
    -   Convert empty strings to nulls (if desired)
    -   Convert types from text to whatever (not shown below)

```{data-file="create_penguins.sql"}
drop table if exists penguins;
.mode csv penguins
.import misc/penguins.csv penguins
update penguins set species = null where species = '';
update penguins set island = null where island = '';
update penguins set bill_length_mm = null where bill_length_mm = '';
update penguins set bill_depth_mm = null where bill_depth_mm = '';
update penguins set flipper_length_mm = null where flipper_length_mm = '';
update penguins set body_mass_g = null where body_mass_g = '';
update penguins set sex = null where sex = '';
```

## Exercise {: .exercise}

What are the data types of the columns in the `penguins` table
created by the CSV import shown above?
How can you correct the ones that need correcting?

## Views

```{data-file="views.sql:keep"}
create view if not exists
active_penguins (
    species,
    island,
    bill_length_mm,
    bill_depth_mm,
    flipper_length_mm,
    body_mass_g,
    sex
) as
select
    species,
    island,
    bill_length_mm,
    bill_depth_mm,
    flipper_length_mm,
    body_mass_g,
    sex
from penguins
where active;

select
    species,
    count(*) as num
from active_penguins
group by species;
```
```{data-file="views.out"}
|  species  | num |
|-----------|-----|
| Chinstrap | 68  |
| Gentoo    | 124 |
```

-   A [view](g:view) is a saved query that other queries can invoke
-   View is re-run each time it's used
-   Like a CTE, but:
    -   Can be shared between queries
    -   Views came first
-   Some databases offer [materialized views](g:materialized_view)
    -   Update-on-demand temporary tables

## Exercise {: .exercise}

Create a view in the lab log database called `busy` with two columns:
`machine_id` and `total_log_length`.
The first column records the numeric ID of each machine;
the second shows the total number of log entries for that machine.

## Check Understanding {: .aside}

<figure id="f:advanced_temp_concept_map">
  <img src="advanced_temp_concept_map.svg" alt="box and arrow diagram showing different kinds of temporary 'tables' in SQL"/>
  <figcaption>Temporary Tables</figcaption>
</figure>

## Hours Reminder {: .aside}

```{data-file="all_jobs.memory.sql"}
create table job (
    name text not null,
    billable real not null
);
insert into job values
('calibrate', 1.5),
('clean', 0.5);
select * from job;
```
```{data-file="all_jobs.memory.out"}
|   name    | billable |
|-----------|----------|
| calibrate | 1.5      |
| clean     | 0.5      |
```

## Adding Checks

```{data-file="all_jobs_check.sql"}
create table job (
    name text not null,
    billable real not null,
    check (billable > 0.0)
);
insert into job values ('calibrate', 1.5);
insert into job values ('reset', -0.5);
select * from job;
```
```{data-file="all_jobs_check.out"}
Runtime error near line 9: CHECK constraint failed: billable > 0.0 (19)
|   name    | billable |
|-----------|----------|
| calibrate | 1.5      |
```

-   `check` adds constraint to table
    -   Must produce a Boolean result
    -   Run each time values added or modified
-   But changes made before the error have taken effect

## Exercise {: .exercise}

Rewrite the definition of the `penguins` table to add the following constraints:

1.  `body_mass_g` must be null or non-negative.

2.  `island` must be one of `"Biscoe"`, `"Dream"`, or `"Torgersen"`.
    (Hint: the `in` operator will be useful here.)

## ACID {: .aside}

-   [Atomic](g:atomic): change cannot be broken down into smaller ones (i.e., all or nothing)
-   [Consistent](g:consistent): database goes from one consistent state to another
-   [Isolated](g:isolated): looks like changes happened one after another
-   [Durable](g:durable): if change takes place, it's still there after a restart

## Transactions

```{data-file="transaction.memory.sql"}
create table job (
    name text not null,
    billable real not null,
    check (billable > 0.0)
);

insert into job values ('calibrate', 1.5);

begin transaction;
insert into job values ('clean', 0.5);
rollback;

select * from job;
```
```{data-file="transaction.memory.out"}
|   name    | billable |
|-----------|----------|
| calibrate | 1.5      |
```

-   Statements outside transaction execute and are committed immediately
-   Statement(s) inside transaction don't take effect until:
    -   `end transaction` (success)
    -   `rollback` (undo)
-   Can have any number of statements inside a transaction
-   But *cannot* nest transactions in SQLite
    -   Other databases support this

## Rollback in Constraints

```{data-file="rollback_constraint.sql"}
create table job (
    name text not null,
    billable real not null,
    check (billable > 0.0) on conflict rollback
);

insert into job values
    ('calibrate', 1.5);
insert into job values
    ('clean', 0.5),
    ('reset', -0.5);

select * from job;
```
```{data-file="rollback_constraint.out"}
Runtime error near line 11: CHECK constraint failed: billable > 0.0 (19)
|   name    | billable |
|-----------|----------|
| calibrate | 1.5      |
```

-   All of second `insert` rolled back as soon as error occurred
-   But first `insert` took effect

## Rollback in Statements

```{data-file="rollback_statement.sql"}
create table job (
    name text not null,
    billable real not null,
    check (billable > 0.0)
);

insert or rollback into job values
('calibrate', 1.5);
insert or rollback into job values
('clean', 0.5),
('reset', -0.5);

select * from job;
```
```{data-file="rollback_statement.out"}
Runtime error near line 11: CHECK constraint failed: billable > 0.0 (19)
|   name    | billable |
|-----------|----------|
| calibrate | 1.5      |
```

-   Constraint is in table definition
-   Action is in statement

## Upsert

```{data-file="upsert.sql"}
create table jobs_done (
    person text unique,
    num integer default 0
);

insert into jobs_done values
('zia', 1);
.print 'after first'
select * from jobs_done;
.print


insert into jobs_done values
('zia', 1);
.print 'after failed'
select * from jobs_done;

insert into jobs_done values
('zia', 1)
on conflict(person) do update set num = num + 1;
.print 'after upsert'
select * from jobs_done;
```
```{data-file="upsert.out"}
after first
| person | num |
|--------|-----|
| zia    | 1   |

Runtime error near line 15: UNIQUE constraint failed: jobs_done.person (19)
after failed
| person | num |
|--------|-----|
| zia    | 1   |
after upsert
| person | num |
|--------|-----|
| zia    | 2   |
```

-   [upsert](g:upsert) stands for "update or insert"
    -   Create if record doesn't exist
    -   Update if it does
-   Not standard SQL but widely implemented
-   Example also shows use of SQLite `.print` command

## Exercise {: .exercise}

Using the assay database,
write a query that adds or modifies people in the `staff` table as shown:

| personal | family | dept | age |
| -------- | ------ | ---- | --- |
| Pranay   | Khanna | mb   | 41  |
| Riaan    | Dua    | gen  | 23  |
| Parth    | Johel  | gen  | 27  |

## Normalization {: .aside}

-   First [normal form](g:normal_form) (1NF):
    every field of every record contains one indivisible value.
-   Second normal form (2NF) and third normal form (3NF):
    every value in a record that isn't a key depends solely on the key,
    not on other values.
-   [Denormalization](g:denormalization): explicitly store values that could be calculated on the fly
    -   To simplify queries and/or make processing faster

## Creating Triggers

```{data-file="trigger_setup.sql"}
-- Track hours of lab work.
create table job (
    person text not null,
    reported real not null check (reported >= 0.0)
);

-- Explicitly store per-person total rather than using sum().
create table total (
    person text unique not null,
    hours real
);

-- Initialize totals.
insert into total values
('gene', 0.0),
('august', 0.0);

-- Define a trigger.
create trigger total_trigger
before insert on job
begin
    -- Check that the person exists.
    select case
        when not exists (select 1 from total where person = new.person)
        then raise(rollback, 'Unknown person ')
    end;
    -- Update their total hours (or fail if non-negative constraint violated).
    update total
    set hours = hours + new.reported
    where total.person = new.person;
end;
```

-   A [trigger](g:trigger) automatically runs before or after a specified operation
-   Can have side effects (e.g., update some other table)
-   And/or implement checks (e.g., make sure other records exist)
-   Add processing overhead…
-   …but data is either cheap or correct, never both
-   Inside trigger, refer to old and new versions of record
    as <code>old.<em>column</em></code> and <code>new.<em>column</em></code>

## Trigger Not Firing

```{data-file="trigger_successful.memory.sql:keep"}
insert into job values
('gene', 1.5),
('august', 0.5),
('gene', 1.0);
```
```{data-file="trigger_successful.memory.out"}
| person | reported |
|--------|----------|
| gene   | 1.5      |
| august | 0.5      |
| gene   | 1.0      |

| person | hours |
|--------|-------|
| gene   | 2.5   |
| august | 0.5   |
```

## Trigger Firing

```{data-file="trigger_firing.sql:keep"}
insert into job values
('gene', 1.0),
('august', -1.0);
```
```{data-file="trigger_firing.out"}
Runtime error near line 6: CHECK constraint failed: reported >= 0.0 (19)

| person | hours |
|--------|-------|
| gene   | 0.0   |
| august | 0.0   |
```

## Exercise {: .exercise}

Using the penguins database:

1.  create a table called `species` with columns `name` and `count`; and

2.  define a trigger that increments the count associated with each species
    each time a new penguin is added to the `penguins` table.

Does your solution behave correctly when several penguins are added
by a single `insert` statement?

## Representing Graphs {: .aside}

```{data-file="lineage_setup.sql"}
create table lineage (
    parent text not null,
    child text not null
);
insert into lineage values
('Arturo', 'Clemente'),
('Darío', 'Clemente'),
('Clemente', 'Homero'),
('Clemente', 'Ivonne'),
('Ivonne', 'Lourdes'),
('Soledad', 'Lourdes'),
('Lourdes', 'Santiago');
```
```{data-file="represent_graph.memory.sql:keep"}
select * from lineage;
```
```{data-file="represent_graph.memory.out"}
|  parent  |  child   |
|----------|----------|
| Arturo   | Clemente |
| Darío    | Clemente |
| Clemente | Homero   |
| Clemente | Ivonne   |
| Ivonne   | Lourdes  |
| Soledad  | Lourdes  |
| Lourdes  | Santiago |
```

<figure id="f:advanced_recursive_lineage">
  <img src="advanced_recursive_lineage.svg" alt="box and arrow diagram showing who is descended from whom in the lineage database"/>
  <figcaption>Lineage Diagram</figcaption>
</figure>

## Exercise {: .exercise}

Write a query that uses a self join to find every person's grandchildren.

## Recursive Queries

```{data-file="recursive_lineage.memory.sql:keep"}
with recursive descendent as (
    select
        'Clemente' as person,
        0 as generations
    union all
    select
        lineage.child as person,
        descendent.generations + 1 as generations
    from descendent inner join lineage
        on descendent.person = lineage.parent
)

select
    person,
    generations
from descendent;
```
```{data-file="recursive_lineage.memory.out"}
|  person  | generations |
|----------|-------------|
| Clemente | 0           |
| Homero   | 1           |
| Ivonne   | 1           |
| Lourdes  | 2           |
| Santiago | 3           |
```

-   Use a [recursive CTE](g:recursive_cte) to create a temporary table (`descendent`)
-   [Base case](g:base_case) seeds this table
-   [Recursive case](g:recursive_case) relies on value(s) already in that table and external table(s)
-   `union all` to combine rows
    -   Can use `union` but that has lower performance (must check uniqueness each time)
-   Stops when the recursive case yields an empty row set (nothing new to add)
-   Then select the desired values from the CTE

## Exercise {: .exercise}

Modify the recursive query shown above to use `union` instead of `union all`.
Does this affect the result?
Why or why not?

## Contact Tracing Database {: .aside}

```{data-file="contact_person.contacts.sql"}
select * from person;
```
```{data-file="contact_person.contacts.out"}
| ident |         name          |
|-------|-----------------------|
| 1     | Juana Baeza           |
| 2     | Agustín Rodríquez     |
| 3     | Ariadna Caraballo     |
| 4     | Micaela Laboy         |
| 5     | Verónica Altamirano   |
| 6     | Reina Rivero          |
| 7     | Elias Merino          |
| 8     | Minerva Guerrero      |
| 9     | Mauro Balderas        |
| 10    | Pilar Alarcón         |
| 11    | Daniela Menéndez      |
| 12    | Marco Antonio Barrera |
| 13    | Cristal Soliz         |
| 14    | Bernardo Narváez      |
| 15    | Óscar Barrios         |
```
```{data-file="contact_contacts.contacts.sql"}
select * from contact;
```
```{data-file="contact_contacts.contacts.out"}
|       left        |         right         |
|-------------------|-----------------------|
| Agustín Rodríquez | Ariadna Caraballo     |
| Agustín Rodríquez | Verónica Altamirano   |
| Juana Baeza       | Verónica Altamirano   |
| Juana Baeza       | Micaela Laboy         |
| Pilar Alarcón     | Reina Rivero          |
| Cristal Soliz     | Marco Antonio Barrera |
| Cristal Soliz     | Daniela Menéndez      |
| Daniela Menéndez  | Marco Antonio Barrera |
```

<figure id="f:advanced_recursive_contacts">
  <img src="advanced_recursive_contacts.svg" alt="box and line diagram showing who has had contact with whom"/>
  <figcaption>Contact Diagram</figcaption>
</figure>

## Bidirectional Contacts

```{data-file="bidirectional.sql:keep"}
create temporary table bi_contact (
    left text,
    right text
);

insert into bi_contact
select
    left, right from contact
    union all
    select right, left from contact
;
```
```{data-file="bidirectional.out"}
| original_count |
|----------------|
| 8              |

| num_contact |
|-------------|
| 16          |
```

-   Create a [temporary table](g:temporary_table) rather than using a long chain of CTEs
    -   Only lasts as long as the session (not saved to disk)
-   Duplicate information rather than writing more complicated query

## Updating Group Identifiers

```{data-file="update_group_ids.sql:keep"}
select
    left.name as left_name,
    left.ident as left_ident,
    right.name as right_name,
    right.ident as right_ident,
    min(left.ident, right.ident) as new_ident
from
    (person as left join bi_contact on left.name = bi_contact.left)
    join person as right on bi_contact.right = right.name;
```
```{data-file="update_group_ids.out"}
|       left_name       | left_ident |      right_name       | right_ident | new_ident |
|-----------------------|------------|-----------------------|-------------|-----------|
| Juana Baeza           | 1          | Micaela Laboy         | 4           | 1         |
| Juana Baeza           | 1          | Verónica Altamirano   | 5           | 1         |
| Agustín Rodríquez     | 2          | Ariadna Caraballo     | 3           | 2         |
| Agustín Rodríquez     | 2          | Verónica Altamirano   | 5           | 2         |
| Ariadna Caraballo     | 3          | Agustín Rodríquez     | 2           | 2         |
| Micaela Laboy         | 4          | Juana Baeza           | 1           | 1         |
| Verónica Altamirano   | 5          | Agustín Rodríquez     | 2           | 2         |
| Verónica Altamirano   | 5          | Juana Baeza           | 1           | 1         |
| Reina Rivero          | 6          | Pilar Alarcón         | 10          | 6         |
| Pilar Alarcón         | 10         | Reina Rivero          | 6           | 6         |
| Daniela Menéndez      | 11         | Cristal Soliz         | 13          | 11        |
| Daniela Menéndez      | 11         | Marco Antonio Barrera | 12          | 11        |
| Marco Antonio Barrera | 12         | Cristal Soliz         | 13          | 12        |
| Marco Antonio Barrera | 12         | Daniela Menéndez      | 11          | 11        |
| Cristal Soliz         | 13         | Daniela Menéndez      | 11          | 11        |
| Cristal Soliz         | 13         | Marco Antonio Barrera | 12          | 12        |
```

-   `new_ident` is minimum of own identifier and identifiers one step away
-   Doesn't keep people with no contacts

## Recursive Labeling

```{data-file="recursive_labeling.contacts.sql:keep"}
with recursive labeled as (
    select
        person.name as name,
        person.ident as label
    from
        person
    union -- not 'union all'
    select
        person.name as name,
        labeled.label as label
    from
        (person join bi_contact on person.name = bi_contact.left)
        join labeled on bi_contact.right = labeled.name
    where labeled.label < person.ident
)
select name, min(label) as group_id
from labeled
group by name
order by label, name;
```
```{data-file="recursive_labeling.contacts.out"}
|         name          | group_id |
|-----------------------|----------|
| Agustín Rodríquez     | 1        |
| Ariadna Caraballo     | 1        |
| Juana Baeza           | 1        |
| Micaela Laboy         | 1        |
| Verónica Altamirano   | 1        |
| Pilar Alarcón         | 6        |
| Reina Rivero          | 6        |
| Elias Merino          | 7        |
| Minerva Guerrero      | 8        |
| Mauro Balderas        | 9        |
| Cristal Soliz         | 11       |
| Daniela Menéndez      | 11       |
| Marco Antonio Barrera | 11       |
| Bernardo Narváez      | 14       |
| Óscar Barrios         | 15       |
```

-   Use `union` instead of `union all` to prevent [infinite recursion](g:infinite_recursion)

## Exercise {: .exercise}

Modify the query above to use `union all` instead of `union` to trigger infinite recursion.
How can you modify the query so that it stops at a certain depth
so that you can trace its output?

## Check Understanding {: .aside}

<figure id="f:advanced_cte_concept_map">
  <img src="advanced_cte_concept_map.svg" alt="box and arrow diagram showing concepts related to common table expressions in SQL"/>
  <figcaption>Common Table Expression Concepts</figcaption>
</figure>
