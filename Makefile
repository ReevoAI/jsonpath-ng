OK_COLOR=\033[32;01m
NO_COLOR=\033[0m

all: lint unit

export PYTHONPATH:=${PWD}
version=`python -c 'import jsonpath_ng; print(jsonpath_ng.__version__)'`
filename=jsonpath_ng-`python -c 'import jsonpath_ng; print(jsonpath_ng.__version__)'`.tar.gz

apidocs:
	@sphinx-apidoc -f --follow-links -H "API documentation" -o docs/source jsonpath_ng

htmldocs:
	@rm -rf docs/_build
	$(MAKE) -C docs html

install:
	@uv sync --all-extras

lint:
	@echo "$(OK_COLOR)==> Linting code ...$(NO_COLOR)"
	@uv run flake8 --exclude=tests,venv,.venv,build,dist jsonpath_ng

test: clean
	@echo "$(OK_COLOR)==> Running tests ...$(NO_COLOR)"
	@uv run tox

tag:
	@echo "$(OK_COLOR)==> Creating tag $(version) ...$(NO_COLOR)"
	@git tag -a "v$(version)" -m "Version $(version)"
	@echo "$(OK_COLOR)==> Pushing tag $(version) to origin ...$(NO_COLOR)"
	@git push origin "v$(version)"

bump:
	@bumpversion --commit --tag --current-version $(version) patch jsonpath_ng/__init__.py --allow-dirty

bump-minor:
	@bumpversion --commit --tag --current-version $(version) minor jsonpath_ng/__init__.py --allow-dirty

history:
	@git changelog --tag $(version)

clean:
	@echo "$(OK_COLOR)==> Cleaning up files that are already in .gitignore...$(NO_COLOR)"
	@git clean -Xf

publish:
	@echo "$(OK_COLOR)==> Releasing package ...$(NO_COLOR)"
	@uv build
	@uv run twine upload dist/*
	@rm -fr build dist .egg pook.egg-info
