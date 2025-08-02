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
