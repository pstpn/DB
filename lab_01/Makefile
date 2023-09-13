gen:
	# - mkdir ./data
	python src/generate.py

copy:
	psql -d lab_01 -U postgres -f .\src\sql\copy.sql

.PHONY: gen