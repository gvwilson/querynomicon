"""Create penguins database in DuckDB, including randomized little penguins.

This mirrors the behavior of bin/create_penguins.py (SQLite) but writes
DuckDB format and uses the DuckDB Python API.
"""

import csv
import random
import sys

import duckdb

SEED = 571289354
LITTLE_SIZE = 10

CREATE = """\
drop table if exists penguins;
create table penguins (
    species text,
    island text,
    bill_length_mm double,
    bill_depth_mm double,
    flipper_length_mm double,
    body_mass_g double,
    sex text
);

drop table if exists little_penguins;
create table little_penguins (
    species text,
    island text,
    bill_length_mm double,
    bill_depth_mm double,
    flipper_length_mm double,
    body_mass_g double,
    sex text
);
"""


def _float(x):
    return None if x == "" else float(x)


def _text(x):
    return None if x == "" else x


FIELDS = [_text, _text, _float, _float, _float, _float, _text]


def main():
    """Main driver."""
    db_name = sys.argv[1]
    csv_name = sys.argv[2]

    conn = duckdb.connect(db_name)

    # DuckDB Python execute supports multiple statements separated by ';'
    conn.execute(CREATE)

    # Read and coerce CSV rows like the original script
    with open(csv_name, newline="", encoding="utf-8") as fh:
        reader = csv.reader(fh)
        rows = []
        for i, row in enumerate(reader):
            if i == 0:
                # header
                assert len(row) == len(FIELDS)
                continue
            assert len(row) == len(FIELDS)
            rows.append([f(val) for f, val in zip(FIELDS, row)])

    # Insert full dataset
    spots = ", ".join(["?"] * len(FIELDS))
    conn.executemany(f"insert into penguins values ({spots});", rows)

    # Create deterministic sample of LITTLE_SIZE rows for little_penguins
    random.seed(SEED)
    sample = random.sample(rows, LITTLE_SIZE)
    conn.executemany(f"insert into little_penguins values ({spots});", sample)

    conn.commit()
    conn.close()


if __name__ == "__main__":
    main()
