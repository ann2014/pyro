.PHONY: all install docs lint format test integration-test clean FORCE

all: docs test

install: FORCE
	pip install -e .[dev,profile]

uninstall :FORCE
	pip uninstall pyro-ppl

docs: FORCE
	$(MAKE) -C docs html

apidoc: FORCE
	$(MAKE) -C docs apidoc

lint: FORCE
	flake8

scrub: FORCE
	find tutorial -name "*.ipynb" | xargs python -m nbstripout --keep-output --keep-count
	find tutorial -name "*.ipynb" | xargs python tutorial/source/cleannb.py

format: FORCE
	yapf -i *.py pyro/distributions/*.py profiler/*.py docs/source/conf.py
	isort --recursive *.py pyro/ tests/ profiler/*.py docs/source/conf.py

perf-test: FORCE
	bash scripts/perf_test.sh ${ref}

profile: ref=dev

profile: FORCE
	bash scripts/profile_model.sh ${ref} ${models}

test: lint docs FORCE
	pytest -vx -n auto --stage unit

test-examples: lint FORCE
	pytest -vx -n auto --stage test_examples

test-tutorials: lint FORCE
	CI=1 grep -l smoke_test tutorial/source/*.ipynb \
	  | xargs pytest -vx --nbval-lax

integration-test: lint FORCE
	pytest -vx -n auto --stage integration

test-all: lint FORCE
	pytest -vx -n auto
	CI=1 grep -l smoke_test tutorial/source/*.ipynb \
	  | xargs pytest -vx --nbval-lax

test-cuda: lint FORCE
	PYRO_TENSOR_TYPE=torch.cuda.DoubleTensor pytest -vx -n 8 --stage unit

clean: FORCE
	git clean -dfx -e pyro-egg.info

FORCE:
