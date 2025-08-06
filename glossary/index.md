# Glossary

## 1

<span id="1_to_1">1-to-1 relation</span>
:   A relationship between two tables in which each record from the first table
    matches exactly one record from the second and vice versa.

<span id="1_to_many">1-to-many relation</span>
:   A relationship between two tables in which each record from the first table
    matches zero or more records from the second,
    but each record from the second table matches exactly one record from the first.

## A

<span id="admin_command">administration command</span>
:   A command for managing a database that isn't part of the SQL standard.
    Each [RDBMS](g:rdbms) has its own idiosyncratic admin commands.

<span id="aggregation">aggregation</span>
:   Combining several values to produce one.

<span id="aggregation_func">aggregation function</span>
:   A function used to produce one value from many,
    such as maximum or addition.

<span id="alias">alias</span>
:   An alternate name used temporarily for a table or column.

<span id="atomic">atomic</span>
:   An operation that cannot be broken into smaller operations.

<span id="autoincrement">autoincrement</span>
:   Automatically add one to a value.

## B

<span id="b_tree">B-tree</span>
:   A self-balancing tree data structure that allows search, insertion, and deletion
    in logarithmic time.

<span id="base_case">base case</span>
:   A starting point for recursion that does not depend on previous recursive calculations.

<span id="blob">Binary Large Object (blob)</span>
    Bytes that are handled as-is rather than being interpreted as numbers, text, or other data types.

## C

<span id="client_server_db">client-server database</span>
:   A database that is managed by its own server process
    that clients interact with through network connections.
    The term is used in contrast to [local database](g:local_db).

<span id="cross_join">cross join</span>
:   A join that creates the cross-product of rows from two tables.

<span id="cte">common table expression (CTE)</span>
    A temporary table created at the start of a query,
    usually to simplify writing the query.

<span id="consistent">consistent</span>
:   A state in which all constraints are satisfied,
    e.g.,
    all columns contain allowed values
    and all foreign keys refer to primary keys.

<span id="correlated_subquery">correlated subquery</span>
:   A subquery that depends on a value or values from the enclosing query,
    and which must therefore be executed once for each of those values.

<span id="csv">comma-separated values (CSV)</span>
    A text format for tabular data that uses commas to separate columns.

<span id="cursor">cursor</span>
:   A reference to the current location in the results of an ongoing query.

## D

<span id="data_migration">data migration</span>
:   To move data from one form to another,
    e.g.,
    from one set of tables to a new set
    or from one DBMS to another.

<span id="database">database</span>
:   A collection of data that can be searched and retrieved.

<span id="dbms">database management system (DBMS)</span>
    A program that manages a particular kind of database.

<span id="denormalization">denormalization</span>
:   To deliberately introduce duplication or other violate normal forms,
    typically to improve query performance.

<span id="durable">durable</span>
:   Guaranteed to survive shutdown and restart.

## E

<span id="er_diagram">entity-relationship diagram</span>
:   A graphical depiction of the relationships between tables in a database.

<span id="exclusive_or">exclusive or</span>
:   A Boolean operation that is true if either but not both of its conditions are true.
    SQL does not provide an exclusive or operator,
    but the same result can be achieved using operators it has.

<span id="expression">expression</span>
:   A part of a program that produces a value, such as `1+2`.

## F

<span id="filter">filter</span>
:   To select records based on whether they pass some Boolean test.

<span id="foreign_key">foreign key</span>
:   A value in one table that identifies a primary key in another table.

<span id="full_outer_join">full outer join</span>
:   A join that produces the union of a left outer join and a right outer join.

## G

<span id="group">group</span>
:   A set of records that share a common property,
    such as having the same value in a particular column.

## H

## I

<span id="in_memory_db">in-memory database</span>
:   A database that is stored in memory rather than on disk.

<span id="inclusive_or">inclusive or</span>
:   A Boolean operator that is true if either or both of its conditions are true.
    SQL's `or` is inclusive.

<span id="index">index</span>
:   An auxiliary data structure that enables faster access to records.

<span id="infinite_recursion">infinite recursion</span>
:   See "infinite recursion".

<span id="isolated">isolated</span>
:   The appearance of having executed in an otherwise-idle system.

## J

<span id="join">join</span>
:   To combine records from two tables.

<span id="join_condition">join condition</span>
:   The criteria used to decide which rows from each table in a join are combined.

<span id="join_table">join table</span>
:   A table that exists solely to enable information from two tables to be connected.

<span id="json">JavaScript Object Notation (JSON)</span>
    A text format for representing numbers, strings, lists, and key-value maps.

## K

## L

<span id="left_outer_join">left outer join</span>
:   A join that is guaranteed to keep all rows from the first (left) table.
    Columns from the right table are filled with actual values if available
    or with null otherwise.

<span id="local_db">local database</span>
:   A database that is stored on the same computer as the application using it
    and accessed directly through function calls.
    The term is used in contrast to [client-server database](g:client_server_db).

## M

<span id="many_to_many">many-to-many relation</span>
:   A relationship between two tables in which each record from the first table
    may match zero or more records from the second and vice versa.

<span id="materialized_view">materialized view</span>
:   A view that is stored on disk and updated on demand.

## N

<span id="normal_form">normal form</span>
:   One of several (loosely defined) rules for organizing data in tables.

<span id="nosql">NoSQL database</span>
:   Any database that doesn't use the relational model.

<span id="null">null</span>
:   A special value representing "not known".

## O

<span id="orm">object-relational mapper (ORM)</span>
    A library that translates objects in a program into database queries
    and the results of those queries back into objects.

## P

<span id="path_expression">path expression</span>
:   An expression identifying an element or a set of elements in a JSON structure.

<span id="primary_key">primary key</span>
:   A value or values in a database table that uniquely identifies each record in that table.

<span id="privilege">privilege</span>
:   The ability to take an action such as querying a table or deleting records.

## Q

<span id="query">query</span>
:   A command to perform some operation in a database (typically data retrieval).

<span id="query_builder">query builder</span>
:   A library that constructs objects representing the parts of a query
    and then translates those objects into a SQL string.

## R

<span id="recursive_cte">recursive CTE</span>
:   A common table expression that refers to itself.
    Every recursive CTE must have a base case and a recursive case.

<span id="recursive_case">recursive case</span>
:   The second or subsequent step in self-referential accumulation of data.

<span id="rdbms">relational database management system (RDBMS)</span>
    A database management system that stores data in tables with columns and rows.

<span id="right_outer_join">right outer join</span>
:   A join that is guaranteed to keep all rows from the second (right) table.
    Columns from the left table are filled with actual values if available
    or with null otherwise.
    SQLite does not implement right outer join
    since its behavior can be reproduced by swapping the order of the tables
    and using a left outer join.

<span id="role">role</span>
:   A collection of [privileges](g:privilege) in a database or other system
    that defines the set of operations a class of users can perform.

## S

<span id="statement">statement</span>
:   A part of a program that doesn't produce a value.

<span id="subquery">subquery</span>
:   A query used within another query.

## T

<span id="table">table</span>
:   A collection of related data in a [database](g:database)
    stored in columns and rows.

<span id="table_valued_func">table-valued function</span>
:   A function that returns multiple values rather than a single value.

<span id="temporary_table">temporary table</span>
:   A table that is explicitly constructed in memory outside any particular query.

<span id="ternary_logic">ternary logic</span>
:   A logic based on three values: true, false, and "don't know" (represented as null).

<span id="tombstone">tombstone</span>
:   A marker value added to a record to show that it is no longer active.
    Tombstones are used as an alternative to deleting data.

<span id="trigger">trigger</span>
:   An action that runs automatically when something happens in a database,
    typically insertion or deletion.

## U

<span id="upsert">upsert</span>
:   To update a record if it exists
    or insert (create) a new record if it doesn't.

<span id="uri">Uniform Resource Identifier (URI)</span>
    A string that identifies a resource (such as a web page or database)
    and the protocol used to access it.

## V

<span id="vectorization">vectorization</span>
:   Performing the same operation on a stream of values
    rather than using a loop to operate on one value at a time.

<span id="view">view</span>
:   A rearrangement of data in a database that is regenerated on demand.

## W

<span id="window_func">window function</span>
:   A function that combines data from adjacent rows in a database query's result.

## X

## Y

## Z
