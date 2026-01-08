# R

<p id="terms"></p>

## Loading Libraries

```{.r data-file="load_connect.r"}
library(dplyr)
```
```{.text data-file="load_connect.out"}
## 
## Attaching package: 'dplyr'

## The following objects are masked from 'package:stats':
## 
##     filter, lag

## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union

## [1] "little_penguins" "penguins"
```

-   Use `dplyr` to create queries
-   Database connections are coordinated by the DBI (DataBase Interface) package

## What Do We Have?

-  List tables with `dbListTables`

```{.r data-file="list_tables.r"}
connection <- DBI::dbConnect(RSQLite::SQLite(), 'data/penguins.db')
DBI::dbListTables(connection)
```
```{.text data-file="list_tables.out"}
## [1] "little_penguins" "penguins"
```

## Load Table as Dataframe

```{.r data-file="get_table.r"}
penguins <- dplyr::tbl(connection, 'penguins')
penguins
```
```{.text data-file="get_table.out"}
## # Source:   table<`penguins`> [?? x 7]
## # Database: sqlite 3.45.2 [/Users/tut/data/penguins.db]
##    species island    bill_length_mm bill_depth_mm flipper_length_mm body_mass_g
##    <chr>   <chr>              <dbl>         <dbl>             <dbl>       <dbl>
##  1 Adelie  Torgersen           39.1          18.7               181        3750
##  2 Adelie  Torgersen           39.5          17.4               186        3800
##  3 Adelie  Torgersen           40.3          18                 195        3250
##  4 Adelie  Torgersen           NA            NA                  NA          NA
##  5 Adelie  Torgersen           36.7          19.3               193        3450
##  6 Adelie  Torgersen           39.3          20.6               190        3650
##  7 Adelie  Torgersen           38.9          17.8               181        3625
##  8 Adelie  Torgersen           39.2          19.6               195        4675
##  9 Adelie  Torgersen           34.1          18.1               193        3475
## 10 Adelie  Torgersen           42            20.2               190        4250
## # ℹ more rows
## # ℹ 1 more variable: sex <chr>
```

-   Retrieve a table with `tbl` function
    -   It need a connection and the name of the table

## How Did We Get Here?

```{.r data-file="show_query.r"}
penguins |> 
  dplyr::show_query()
```
```{.text data-file="show_query.out"}
## <SQL>
## SELECT *
## FROM `penguins`
```

-   `dplyr` functions generate `SELECT` statements
-   `show_query()` runs the SQL `EXPLAIN` command to show the SQL query

## Lazy Evaluation

```{.r data-file="filter_lazy.r"}
penguins |> 
  filter(species == "Adelie")
```
```{.text data-file="filter_lazy.out"}
## # Source:   SQL [?? x 7]
## # Database: sqlite 3.45.2 [/Users/tut/data/penguins.db]
##    species island    bill_length_mm bill_depth_mm flipper_length_mm body_mass_g
##    <chr>   <chr>              <dbl>         <dbl>             <dbl>       <dbl>
##  1 Adelie  Torgersen           39.1          18.7               181        3750
##  2 Adelie  Torgersen           39.5          17.4               186        3800
##  3 Adelie  Torgersen           40.3          18                 195        3250
##  4 Adelie  Torgersen           NA            NA                  NA          NA
##  5 Adelie  Torgersen           36.7          19.3               193        3450
##  6 Adelie  Torgersen           39.3          20.6               190        3650
##  7 Adelie  Torgersen           38.9          17.8               181        3625
##  8 Adelie  Torgersen           39.2          19.6               195        4675
##  9 Adelie  Torgersen           34.1          18.1               193        3475
## 10 Adelie  Torgersen           42            20.2               190        4250
## # ℹ more rows
## # ℹ 1 more variable: sex <chr>
```

-   `filter` generates a query using `WHERE <condition>` 
-   `dbplyr` call are lazy.
-   The SQL query is only evaluated when it is sent to the database
-   Running the `dplyr` call only returns a preview of the result

```{.r data-file="filter_collect.r"}
penguins |> 
  filter(species == "Adelie") |> 
  collect()
```
```{.text data-file="filter_collect.out"}
## # A tibble: 152 × 7
##    species island    bill_length_mm bill_depth_mm flipper_length_mm body_mass_g
##    <chr>   <chr>              <dbl>         <dbl>             <dbl>       <dbl>
##  1 Adelie  Torgersen           39.1          18.7               181        3750
##  2 Adelie  Torgersen           39.5          17.4               186        3800
##  3 Adelie  Torgersen           40.3          18                 195        3250
##  4 Adelie  Torgersen           NA            NA                  NA          NA
##  5 Adelie  Torgersen           36.7          19.3               193        3450
##  6 Adelie  Torgersen           39.3          20.6               190        3650
##  7 Adelie  Torgersen           38.9          17.8               181        3625
##  8 Adelie  Torgersen           39.2          19.6               195        4675
##  9 Adelie  Torgersen           34.1          18.1               193        3475
## 10 Adelie  Torgersen           42            20.2               190        4250
## # ℹ 142 more rows
## # ℹ 1 more variable: sex <chr>
```

-   `collect` retrieves the complete result of the query
    -   Note that now the table has 152 rows

## Selecting Columns

```{.r data-file="select.r"}
penguins |> 
  select(species, island, contains('bill'))
```
```{.text data-file="select.out"}
## # Source:   SQL [?? x 4]
## # Database: sqlite 3.45.2 [C:\Users\tonin\Documents\Courses\r-sql\data\penguins.db]
##    species island    bill_length_mm bill_depth_mm
##    <chr>   <chr>              <dbl>         <dbl>
##  1 Adelie  Torgersen           39.1          18.7
##  2 Adelie  Torgersen           39.5          17.4
##  3 Adelie  Torgersen           40.3          18  
##  4 Adelie  Torgersen           NA            NA  
##  5 Adelie  Torgersen           36.7          19.3
##  6 Adelie  Torgersen           39.3          20.6
##  7 Adelie  Torgersen           38.9          17.8
##  8 Adelie  Torgersen           39.2          19.6
##  9 Adelie  Torgersen           34.1          18.1
## 10 Adelie  Torgersen           42            20.2
## # ℹ more rows
```

-   R's `select` modifies the SQL `SELECT` statement
-   Selection helpers from `dplyr` (like `contains`) work

## Sorting

```{.r data-file="sort.r"}
penguins |> 
  select(species, body_mass_g) |> 
  arrange(body_mass_g)
```
```{.text data-file="sort.out"}
## # Source:     SQL [?? x 2]
## # Database:   sqlite 3.45.2 [C:\Users\tonin\Documents\Courses\r-sql\data\penguins.db]
## # Ordered by: body_mass_g
##    species   body_mass_g
##    <chr>           <dbl>
##  1 Adelie             NA
##  2 Gentoo             NA
##  3 Chinstrap        2700
##  4 Adelie           2850
##  5 Adelie           2850
##  6 Adelie           2900
##  7 Adelie           2900
##  8 Adelie           2900
##  9 Chinstrap        2900
## 10 Adelie           2925
## # ℹ more rows
```

-   With `arrange` you `ORDER BY` the data
-   There is a `desc` function

## Exercise {: .exercise}

Find the lightest penguin on Dream Island by arranging the table accordingly.
Only show the species, island, and body mass.

### Solution

```{.r data-file="ex_lightest_penguin.r"}
penguins |> 
  select(species, island, body_mass_g) |> 
  filter(island == 'Dream') |> 
  arrange(desc(body_mass_g))
```
```{.text data-file="ex_lightest_penguin.out"}
## # Source:     SQL [?? x 3]
## # Database:   sqlite 3.45.2 [C:\Users\tonin\Documents\Courses\r-sql\data\penguins.db]
## # Ordered by: desc(body_mass_g)
##    species   island body_mass_g
##    <chr>     <chr>        <dbl>
##  1 Chinstrap Dream         4800
##  2 Adelie    Dream         4650
##  3 Adelie    Dream         4600
##  4 Chinstrap Dream         4550
##  5 Chinstrap Dream         4500
##  6 Adelie    Dream         4475
##  7 Adelie    Dream         4450
##  8 Chinstrap Dream         4450
##  9 Adelie    Dream         4400
## 10 Chinstrap Dream         4400
## # ℹ more rows
```

## Transforming Columns 

```{.r data-file="mutate.r"}
penguins |> 
  mutate(weight_kg = body_mass_g/1000)
```
```{.text data-file="mutate.out"}
## # Source:   SQL [?? x 8]
## # Database: sqlite 3.45.2 [C:\Users\tonin\Documents\Courses\r-sql\data\penguins.db]
##    species island    bill_length_mm bill_depth_mm flipper_length_mm body_mass_g
##    <chr>   <chr>              <dbl>         <dbl>             <dbl>       <dbl>
##  1 Adelie  Torgersen           39.1          18.7               181        3750
##  2 Adelie  Torgersen           39.5          17.4               186        3800
##  3 Adelie  Torgersen           40.3          18                 195        3250
##  4 Adelie  Torgersen           NA            NA                  NA          NA
##  5 Adelie  Torgersen           36.7          19.3               193        3450
##  6 Adelie  Torgersen           39.3          20.6               190        3650
##  7 Adelie  Torgersen           38.9          17.8               181        3625
##  8 Adelie  Torgersen           39.2          19.6               195        4675
##  9 Adelie  Torgersen           34.1          18.1               193        3475
## 10 Adelie  Torgersen           42            20.2               190        4250
## # ℹ more rows
## # ℹ 2 more variables: sex <chr>, weight_kg <dbl>
```

-   `mutate` also modifies the `SELECT` statement
    -   Naming the new variable works as the `AS` statement
    -   It is optional, but desirable.
-   If `select` it not present the query will return all the columns

## Aggregating 

```{.r data-file="aggregate.r"}
penguins |> 
  group_by(species) |> 
  summarise(avg_body_mas = mean(body_mass_g))
```
```{.text data-file="aggregate.out"}
## Warning: Missing values are always removed in SQL aggregation functions.
## Use `na.rm = TRUE` to silence this warning
## This warning is displayed once every 8 hours.

## # Source:   SQL [3 x 2]
## # Database: sqlite 3.45.2 [C:\Users\tonin\Documents\Courses\r-sql\data\penguins.db]
##   species   avg_body_mas
##   <chr>            <dbl>
## 1 Adelie           3701.
## 2 Chinstrap        3733.
## 3 Gentoo           5076.
```

-   `summarise` and `group_by` work together to generate a `GROUP BY` clause
-   `dplyr` defaults to SQL to handle missing values unless you use the `na.rm` argument in aggregation functions

## Exercise {: .exercise}

-   Calculate the ratio of bill length to bill depth for each penguin
-   Using the previous result, calculate the average ratio for each species

## Creating a Table

```{.r data-file="create_table.r"}
library(DBI)

another_connection <- dbConnect(RSQLite::SQLite(), ':memory:')

table1 <- tibble(
  person = c('mik', 'mik', 'mik', 'po', 'po', 'tay'),
  job = c('calibrate', 'clean', 'complain', 'clean', 'complain', 'complain')
)

dbWriteTable(another_connection, "work", table1, row.names = FALSE, overwrite = TRUE)

work <- tbl(another_connection, "work")
```

-   Write, overwrite, or append a data frame to a database table with `dbWriteTable` 
    -   `':memory:'` is a "path" that creates an in-memory database

## Exercise {: .exercise}

Create the table `job` with the values shown in the table below.

|   name    | billable |
|-----------|----------|
| calibrate | 1.5      |
| clean     | 0.5      |

### Solution

```{.r data-file="ex_job_table.r"}
table2 <- tibble(
  name = c('calibrate', 'clean'),
  billable = c(1.5, 0.5)
)

dbWriteTable(another_connection, "job", table2, row.names = FALSE, overwrite = TRUE)

job <- tbl(another_connection, "job")
```

## Negation Done Wrong

-   Who doesn't calibrate?

```{.r data-file="negate_wrong.r"}
work |> 
  filter(job != 'calibrate') |> 
  distinct(person)
```
```{.text data-file="negate_wrong.out"}
## # Source:   SQL [3 x 1]
## # Database: sqlite 3.45.2 [:memory:]
##   person
##   <chr> 
## 1 mik   
## 2 po    
## 3 tay
```

-   Similar to pure SQL, the result is wrong (Mik does calibrate)
    -   But using subqueries with `dplyr` is not that simple

## Literal SQL

```{.r data-file="literal_sql.r"}
work |> 
  filter(!person %in% sql(
    # subquery
    "(SELECT DISTINCT person FROM work
    where job = 'calibrate')"
  )) |> 
  distinct(person) 
```

-   You can use literal SQL inside `sql`
    -   It returns an SQL object
-   Useful when R code is not enough to write a query

## Joining Tables

```{.r data-file="join.r"}
does_calibrate <- work |> 
  filter(job == 'calibrate')

work |> 
  anti_join(does_calibrate, by = join_by(person)) |> 
  distinct(person) |> 
  collect() 
```
```{.text data-file="join.out"}
## # A tibble: 2 × 1
##   person
##   <chr> 
## 1 po    
## 2 tay
```

-   Joining tables with `dplyr` works as it does in SQL
    -   The `by` argument works as the `ON` statement
    -   In this case we join by `person`
-   Use `left_join`, `right_join`, `inner_join` or `full_join`
  
## Exercise {: .exercise}

Calculate how may hours each person worked by summing all jobs.

### Solution

```{.r data-file="ex_join.r"}
work |> 
  left_join(job, by = join_by(job == name)) |> 
  group_by(person) |> 
  summarise(total_hours = sum(billable))
```
```{.text data-file="ex_join.out"}
## # Source:   SQL [3 x 2]
## # Database: sqlite 3.45.2 [:memory:]
##   person total_hours
##   <chr>        <dbl>
## 1 mik            2  
## 2 po             0.5
## 3 tay           NA
```
