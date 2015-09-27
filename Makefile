SHELL = /bin/bash

.PHONY: clean clean-pyc clean-dist dist test-travis



clean: clean-dist clean-pyc

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-dist:
	rm -rf target
	rm -rf src/main/python/build
	rm -rf src/main/python/*.egg-info



test: test-python test-java test-integration

test-python:

test-java:



test-integration: \
	test-integration-setup \
	test-integration-matrix \
	test-integration-teardown

install-venv:
	test -d venv || virtualenv venv

install-cassandra-driver: install-venv
	venv/bin/pip install cassandra-driver

install-ccm: install-venv
	venv/bin/pip install ccm

start-cassandra: install-ccm
	mkdir -p ./.ccm
	venv/bin/ccm status --config-dir=./.ccm || venv/bin/ccm create pyspark_test -v 2.1.4 -n 1 -s --config-dir=./.ccm

stop-cassandra:
	venv/bin/ccm remove --config-dir=./.ccm

test-integration-setup: \
	start-cassandra

test-integration-teardown: \
	stop-cassandra

test-integration-matrix: \
	install-cassandra-driver \
	test-integration-spark-1.2.1 \
	test-integration-spark-1.2.2 \
	test-integration-spark-1.3.0 \
	test-integration-spark-1.3.1 \
	test-integration-spark-1.4.1

test-travis: \
  install-cassandra-driver
	$(call test-integration-for-version,$$SPARK_VERSION)

test-integration-spark-1.2.1:
	$(call test-integration-for-version,1.2.1)

test-integration-spark-1.2.2:
	$(call test-integration-for-version,1.2.2)

test-integration-spark-1.3.0:
	$(call test-integration-for-version,1.3.0)

test-integration-spark-1.3.1:
	$(call test-integration-for-version,1.3.1)

test-integration-spark-1.4.1:
	$(call test-integration-for-version,1.4.1)

define test-integration-for-version
	mkdir -p lib && test -d lib/spark-$1-bin-hadoop2.4 || \
		(pushd lib && curl http://ftp.tudelft.nl/apache/spark/spark-$1/spark-$1-bin-hadoop2.4.tgz | tar xz && popd)

	cp log4j.properties lib/spark-$1-bin-hadoop2.4/conf/

	source venv/bin/activate ; \
		lib/spark-$1-bin-hadoop2.4/bin/spark-submit \
			--master local[*] \
			--driver-memory 256m \
			--conf spark.cassandra.connection.host="localhost" \
			--jars target/pyspark_cassandra-0.1.6.jar \
			--py-files target/pyspark_cassandra-0.1.6-py2.7.egg \
			src/test/python/pyspark_cassandra/it_suite.py
endef


dist: dist-python dist-java

dist-python:
	python/setup.py bdist_egg -d ../target

dist-java:
	mvn package


all: clean dist
