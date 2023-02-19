# Format.
f:
	find . -name "*.py" | xargs  \
		poetry run autoflake \
			--in-place \
			--recursive \
			--remove-all-unused-imports \
			--remove-unused-variables \
			--ignore-init-module-imports
	poetry run black . --line-length 80
	poetry run isort .

# Test.
t:
	find . -name "*.py" | xargs python -m doctest
