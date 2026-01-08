# Python

<p id="terms"></p>

## Querying from Python

```{.py data-file="basic_python_query.py"}
import sqlite3
import sys

db_path = sys.argv[1]
connection = sqlite3.connect(db_path)
cursor = connection.execute("select count(*) from penguins;")
rows = cursor.fetchall()
print(rows)
```
```{.text data-file="basic_python_query.out"}
[(344,)]
```

-   `sqlite3` is part of Python's standard library
-   Create a connection to a database file
-   Get a [cursor](g:cursor) by executing a query
    -   More common to create cursor and use that to run queries
-   Fetch all rows at once as list of tuples

## Incremental Fetch

```{.py data-file="incremental_fetch.py"}
import sqlite3
import sys

db_path = sys.argv[1]
connection = sqlite3.connect(db_path)
cursor = connection.cursor()
cursor = cursor.execute("select species, island from penguins limit 5;")
while row := cursor.fetchone():
    print(row)
```
```{.text data-file="incremental_fetch.out"}
('Adelie', 'Torgersen')
('Adelie', 'Torgersen')
('Adelie', 'Torgersen')
('Adelie', 'Torgersen')
('Adelie', 'Torgersen')
```

-   `cursor.fetchone` returns `None` when no more data
-   There is also `fetchmany(N)` to fetch (up to) a certain number of rows

## Insert, Delete, and All That

```{.py data-file="insert_delete.py"}
import sqlite3

connection = sqlite3.connect(":memory:")
cursor = connection.cursor()
cursor.execute("create table example(num integer);")

cursor.execute("insert into example values (10), (20);")
print("after insertion", cursor.execute("select * from example;").fetchall())

cursor.execute("delete from example where num < 15;")
print("after deletion", cursor.execute("select * from example;").fetchall())
```
```{.text data-file="insert_delete.out"}
after insertion [(10,), (20,)]
after deletion [(20,)]
```

-   Each `execute` is its own transaction

## Interpolating Values

```{.py data-file="interpolate.py"}
import sqlite3

connection = sqlite3.connect(":memory:")
cursor = connection.cursor()
cursor.execute("create table example(num integer);")

cursor.executemany("insert into example values (?);", [(10,), (20,)])
print("after insertion", cursor.execute("select * from example;").fetchall())
```
```{.text data-file="interpolate.out"}
after insertion [(10,), (20,)]
```

-   From [XKCD][xkcd_tables]

<figure id="f:python_xkcd">
  <img src="xkcd_327_exploits_of_a_mom.png" alt="XKCD cartoon showing a mother scolding a school for not being more careful about SQL injection attacks"/>
  <figcaption>XKCD "Exploits of a Mom"</figcaption>
</figure>

## Exercise {: .exercise}

Write a Python script that takes island, species, sex, and other values as command-line arguments
and inserts an entry into the penguins database.

## Script Execution

```{.py data-file="script_execution.py"}
import sqlite3

SETUP = """\
drop table if exists example;
create table example(num integer);
insert into example values (10), (20);
"""

connection = sqlite3.connect(":memory:")
cursor = connection.cursor()
cursor.executescript(SETUP)
print("after insertion", cursor.execute("select * from example;").fetchall())
```
```{.text data-file="script_execution.out"}
after insertion [(10,), (20,)]
```

-   But what if something goes wrong?

## SQLite Exceptions in Python

```{.py data-file="exceptions.py"}
import sqlite3

SETUP = """\
create table example(num integer check(num > 0));
insert into example values (10);
insert into example values (-1);
insert into example values (20);
"""

connection = sqlite3.connect(":memory:")
cursor = connection.cursor()
try:
    cursor.executescript(SETUP)
except sqlite3.Error as exc:
    print(f"SQLite exception: {exc}")
print("after execution", cursor.execute("select * from example;").fetchall())
```
```{.text data-file="exceptions.out"}
SQLite exception: CHECK constraint failed: num > 0
after execution [(10,)]
```

## Python in SQLite

```{.py data-file="embedded_python.py"}
import sqlite3

SETUP = """\
create table example(num integer);
insert into example values (-10), (10), (20), (30);
"""


def clip(value):
    if value < 0:
        return 0
    if value > 20:
        return 20
    return value


connection = sqlite3.connect(":memory:")
connection.create_function("clip", 1, clip)
cursor = connection.cursor()
cursor.executescript(SETUP)
for row in cursor.execute("select num, clip(num) from example;").fetchall():
    print(row)
```
```{.text data-file="embedded_python.out"}
(-10, 0)
(10, 10)
(20, 20)
(30, 20)
```

-   SQLite calls back into Python to execute the function
-   Other databases can run Python (and other languages) in the database server process
-   Be careful

## Handling Dates and Times

```{.py data-file="dates_times.py"}
from datetime import date
import sqlite3


# Convert date to ISO-formatted string when writing to database
def _adapt_date_iso(val):
    return val.isoformat()


sqlite3.register_adapter(date, _adapt_date_iso)


# Convert ISO-formatted string to date when reading from database
def _convert_date(val):
    return date.fromisoformat(val.decode())


sqlite3.register_converter("date", _convert_date)

SETUP = """\
create table events(
    happened date not null,
    description text not null
);
"""

connection = sqlite3.connect(":memory:", detect_types=sqlite3.PARSE_DECLTYPES)
cursor = connection.cursor()
cursor.execute(SETUP)

cursor.executemany(
    "insert into events values (?, ?);",
    [(date(2024, 1, 10), "started tutorial"), (date(2024, 1, 29), "finished tutorial")],
)

for row in cursor.execute("select * from events;").fetchall():
    print(row)
```
```{.text data-file="dates_times.out"}
(datetime.date(2024, 1, 10), 'started tutorial')
(datetime.date(2024, 1, 29), 'finished tutorial')
```

-   `sqlite3.PARSE_DECLTYPES` tells `sqlite3` library to use converts based on declared column types
-   Adapt on the way in, convert on the way out

## Exercise {: .exercise}

Write a Python adapter that truncates real values to two decimal places
as they are being written to the database.

## SQL in Jupyter Notebooks

```{.sh data-file="install_jupysql.sh"}
pip install jupysql
```

-   And then inside the notebook:

```{.text data-file="load_ext.text"}
%load_ext sql
```

-   Loads extension

```{.text data-file="jupyter_connect.text"}
%sql sqlite:///db/penguins.db
```
```{.text data-file="jupyter_connect.out"}
Connecting to 'sqlite:///data/penguins.db'
```

-   Connects to database
    -   `sqlite://` with two slashes is the protocol
    -   `/data/penguins.db` (one leading slash) is a local path
-   Single percent sign `%sql` introduces one-line command
-   Use double percent sign `%%sql` to indicate that the rest of the cell is SQL

```{.text data-file="jupyter_select.text"}
%%sql
select species, count(*) as num
from penguins
group by species;
```
```{.text data-file="jupyter_select.out"}
Running query in 'sqlite:///data/penguins.db'
```

<table>
  <thead>
    <tr>
      <th>species</th>
      <th>num</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Adelie</td>
      <td>152</td>
    </tr>
    <tr>
      <td>Chinstrap</td>
      <td>68</td>
    </tr>
    <tr>
      <td>Gentoo</td>
      <td>124</td>
    </tr>
  </tbody>
</table>

## Pandas and SQL

```{.sh data-file="install_pandas.sh"}
pip install pandas
```
```{.py data-file="select_pandas.py"}
import pandas as pd
import sqlite3
import sys

db_path = sys.argv[1]
connection = sqlite3.connect(db_path)
query = "select species, count(*) as num from penguins group by species;"
df = pd.read_sql(query, connection)
print(df)
```
```{.text data-file="select_pandas.out"}
     species  num
0     Adelie  152
1  Chinstrap   68
2     Gentoo  124
```

-   Be careful about datatype conversion when using [Pandas][pandas]

## Exercise {: .exercise}

Write a command-line Python script that uses Pandas to re-create the penguins database.

## Polars and SQL

```{.sh data-file="install_polars.sh"}
pip install polars pyarrow adbc-driver-sqlite
```
```{.py data-file="select_polars.py"}
import polars as pl
import sys

db_path = sys.argv[1]
uri = "sqlite:///{db_path}"
query = "select species, count(*) as num from penguins group by species;"
df = pl.read_database_uri(query, uri, engine="adbc")
print(df)
```
```{.text data-file="select_polars.out"}
shape: (3, 2)
┌───────────┬─────┐
│ species   ┆ num │
│ ---       ┆ --- │
│ str       ┆ i64 │
╞═══════════╪═════╡
│ Adelie    ┆ 152 │
│ Chinstrap ┆ 68  │
│ Gentoo    ┆ 124 │
└───────────┴─────┘
```

-   The [Uniform Resource Identifier](g:uri) (URI) specifies the database
-   The query is the query
-   Use the ADBC engine instead of the default ConnectorX with [Polars][polars]

## Exercise {: .exercise}

Write a command-line Python script that uses Polars to re-create the penguins database.

## Query Builders

-   Use [PyPika][pypika] to build queries

```{.py data-file="builder.py"}
from pypika import Query, Table
import sqlite3
import sys

db_path = sys.argv[1]
connection = sqlite3.connect(db_path)

department = Table("department")
query = Query.from_(department).select("ident", "building", "name")
print("query:", str(query))
cursor = connection.execute(str(query))
for result in cursor.fetchall():
    print(result)
```
```{.text data-file="builder.out"}
query: SELECT "ident","building","name" FROM "department"
('gen', 'Chesson', 'Genetics')
('hist', 'Fashet Extension', 'Histology')
('mb', 'Chesson', 'Molecular Biology')
('end', 'TGVH', 'Endocrinology')
```

-   A [query builder](g:query_builder) creates objects representing the parts of a query
    -   Translate those objects into a SQL string for a particular dialect

```{.py data-file="builder_relation.py"}
department = Table("department")
staff = Table("staff")
query = Query\
    .from_(staff)\
    .join(department)\
    .on(staff.dept == department.ident)\
    .select(staff.personal, staff.family, department.building)
cursor = connection.execute(str(query))
for result in cursor.fetchall():
    print(result)
```
```{.text data-file="builder_relation.out"}
('Divit', 'Dhaliwal', 'Fashet Extension')
('Indrans', 'Sridhar', 'Chesson')
('Pranay', 'Khanna', 'Chesson')
('Vedika', 'Rout', 'Fashet Extension')
('Abram', 'Chokshi', 'Chesson')
('Romil', 'Kapoor', 'Fashet Extension')
('Ishaan', 'Ramaswamy', 'Chesson')
('Nitya', 'Lal', 'Chesson')
```

-   Syntax is similar to that of Pandas and Polars because:
    -   They are all solving the same basic problem
    -   They all borrow ideas from each other

## Object-Relational Mappers

```{.py data-file="orm.py"}
from sqlmodel import Field, Session, SQLModel, create_engine, select
import sys


class Department(SQLModel, table=True):
    ident: str = Field(default=None, primary_key=True)
    name: str
    building: str


db_uri = f"sqlite:///{sys.argv[1]}"
engine = create_engine(db_uri)
with Session(engine) as session:
    statement = select(Department)
    for result in session.exec(statement).all():
        print(result)
```
```{.text data-file="orm.out"}
building='Chesson' name='Genetics' ident='gen'
building='Fashet Extension' name='Histology' ident='hist'
building='Chesson' name='Molecular Biology' ident='mb'
building='TGVH' name='Endocrinology' ident='end'
```

-   An [object-relational mapper](g:orm) (ORM) translates table columns to object properties and vice versa
-   [SQLModel][sqlmodel] relies on Python type hints

## Exercise {: .exercise}

Write a command-line Python script that uses SQLModel to re-create the penguins database.

## Relations with ORMs

```{.py data-file="orm_relation.py:keep"}
class Staff(SQLModel, table=True):
    ident: str = Field(default=None, primary_key=True)
    personal: str
    family: str
    dept: Optional[str] = Field(default=None, foreign_key="department.ident")
    age: int


db_uri = f"sqlite:///{sys.argv[1]}"
engine = create_engine(db_uri)
SQLModel.metadata.create_all(engine)
with Session(engine) as session:
    statement = select(Department, Staff).where(Staff.dept == Department.ident)
    for dept, staff in session.exec(statement):
        print(f"{dept.name}: {staff.personal} {staff.family}")
```
```{.text data-file="orm_relation.out"}
Histology: Divit Dhaliwal
Molecular Biology: Indrans Sridhar
Molecular Biology: Pranay Khanna
Histology: Vedika Rout
Genetics: Abram Chokshi
Histology: Romil Kapoor
Molecular Biology: Ishaan Ramaswamy
Genetics: Nitya Lal
```

-   Make foreign keys explicit in class definitions
-   SQLModel automatically does the join
    -   The two staff with no department aren't included in the result
