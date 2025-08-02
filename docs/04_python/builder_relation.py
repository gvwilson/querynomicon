from pypika import Query, Table
import sqlite3
import sys

db_path = sys.argv[1]
connection = sqlite3.connect(db_path)

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
