COMMIT = $(shell git rev-parse --short HEAD)

.PHONY: build-gosnowflake-example
build-gosnowflake-example:
	docker build \
		--file ./Dockerfile \
		--tag=$(USER)/gosnowflake-example:$(COMMIT) \
		--tag=$(USER)/gosnowflake-example:latest .

.PHONY: gosnowflake-example
gosnowflake-example:
	docker run --rm \
		--dns=8.8.8.8 \
		--env-file ./.env.docker \
		--name=go-snowflake-example \
		--network="host" \
		$(USER)/gosnowflake-example:latest $(ARGS)
