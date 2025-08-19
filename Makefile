# Runnable tasks.

SLUG=querynomicon

include common.mk

all: commands

HTML_IGNORES =

## build: convert to HTML
build:
	@mccole build
	@touch docs/.nojekyll

## links: check links in published site
links:
	linkchecker -F text https://gvwilson.github.io/${SLUG}/

## lint: check code and project
lint:
	@ruff check --exclude docs .
	@mccole lint --html

## serve: serve generated HTML
serve:
	@python -m http.server -d docs

## spelling: check for unknown words
spelling:
	@cat *.md */*.md | aspell list | sort | uniq | diff - extras/words.txt

## databases: make required files
databases : \
	${DB}/assays.db \
	${DB}/contact_tracing.db \
	${DB}/lab_log.db \
	${DB}/penguins.db

${DB}/assays.db: bin/create_assays_db.py
	python $< $@

${DB}/contact_tracing.db: bin/create_contacts.py
	python $< $@

${DB}/lab_log.db: bin/create_lab_log.py
	python $< $@

${DB}/penguins.db : bin/create_penguins.py misc/penguins.csv
	python $< $@ misc/penguins.csv

## psql_db: create PostgreSQL penguins database
psql_db: bin/create_penguins_psql.py
	python $< penguins misc/penguins.csv

## release: create a release
release:
	@rm -rf sql-tutorial.zip
	@zip -r sql-tutorial.zip \
	db \
	misc/penguins.csv \
	src \
	-x \*~
