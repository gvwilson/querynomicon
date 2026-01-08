# Runnable tasks.

SLUG=querynomicon

include common.mk

all: commands

HTML_IGNORES =

## build: convert to HTML
build:
	@mccole build
	@touch docs/.nojekyll
	@cd ./db && zip -r ../docs/databases.zip *.db

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

${DB}/penguins.db : bin/create_penguins.py extras/penguins.csv
	python $< $@ extras/penguins.csv

## psql_db: create PostgreSQL penguins database
psql_db: bin/create_penguins_psql.py
	python $< penguins extras/penguins.csv

## release: create a release
release:
	@rm -rf sql-tutorial.zip
	@zip -r sql-tutorial.zip \
	db \
	extras/penguins.csv \
	src \
	-x \*~
